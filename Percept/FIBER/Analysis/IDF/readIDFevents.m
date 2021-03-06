function[ trials ] = readIDFevents( filename, separator_type, parameters )
%% IDF Event reader v0.4
%
% INPUT  : 1) filename of exported IDF file (SMI GmbH)
%          2) type of trial separator
%               - 'set'
%
%               - 'message',  requires as parameters a string for regular
%                             expression in description of IDF user events
% 
%               - 'time',     requires as parameters a list of timings specified
%                             in seconds.
%          3) optional parameters dependent upon the separator type
%
% OUTPUT : structure-array of trials corresponding with the number of sets in the
%          datafile. Each structure contains the following fields:
%           
%          trial(x).saccades   : structure-array of saccades, each
%                                containing the following fields
%           
%                       .set
%                       .start
%                       .end
%                       .duration
%                       .start_location_x
%          trial(x).fixations  : structure-array of saccades, each
%                                containing the following fields
%
%          trial(x).blinks     : structure-array of saccades, each
%                                containing the following fields
%
%          trial(x).userevents : structure-array of saccades, each
%                                containing the following fields
%
%          trial(x).start      : starttime of first event found in trial(x)
%          trial(x).end        : endtime of last event found in trial(x)
%          trial(x).duration   : trial(x).end - trial(x).start
%
%          trials.filename     : read filename   
%                       
% AUTHOR :
%
% J.B.C. Marsman
% Neuroimaging Center / Laboratory for Experimental Ophtalmology
% University Medical Center Groningen
% The Netherlands
% 
% HISTORY:
%
% 25/01/2007        JBM          Created (set based)
%
% 19/02/2007        JBM          Message based trial separation added
%
% 10/03/2007        JBM          - Event index added
%                                - Removal of short fixations around blinks added                         
%
% 22/05/2007        JBM          Time based trial separation added
%
%
% EXAMPLES:
%
% %% this call will pop a file selection dialog for message based parsing.
% data = readIDFevents('message', 'stimulus');
%
% %% this call will pop a file selection dialog and parse the selected
% %% file based on the array of seconds
% data = readIDFevents('time', [0 2 4 6 8 10]);
%
%

%% define trial separator struct
separator = struct('type', 'set', 'regular_expression', '', 'logfile', '', 'reference_times', [], 'reference_index', 1);

%% parse input parameters
if nargin ==0
    fprintf('Note : parsing file based on set indices.\n');
    fprintf('       for message based separation, type `help readIDFevents`\n');
    filename = user_select_file;
end

%% one argument given
if nargin == 1
    if strcmp(filename, 'set')
       filename = user_select_file;
    elseif strcmp(filename, 'message')
       error('Regular expression required as second argument');
    elseif strcmp(filename, 'time')
       
       separator.type = 'time';    
       filename = user_select_file; %% no idf data, let the user select one
       fprintf('You did not provide an array of timings, please select a log file to extract if from:\n'); 
       [separator.reference_times separator.logfile] = extract_set_timings; %% no array of times provided, let the user select a source logfile
    else
       fprintf('Note : parsing file based on set indices.\n');
       fprintf('       for message based separation, type help readIDFevents\n');
    end
end

%% two arguments given
if nargin == 2
    if strcmp(filename, 'message')
        separator.regular_expression = separator_type;
        separator.type = 'message';
        filename = user_select_file;
    elseif strcmp(separator_type,'message')
         error('Regular expression required as third argument');
    elseif strcmp(filename,'time')
         separator.type = 'time';
         separator.reference_times = separator_type;
         filename = user_select_file;
    end
end

%% three arguments given
if nargin == 3
    if strcmp(separator_type,'message')
        separator.type = 'message';
        separator.regular_expression = parameters;
    elseif strcmp(separator_type,'time')
        separator.type = 'time';
        separator.reference_times = parameters;
    else        
        error(sprintf('incorrect type of parser given.\n\npossible parsers : {set, message, time}'));
    end;
end;



%% open file
file = fopen(filename, 'r');
              
d_index = 1;
fixation_index = 1;
saccade_index  = 1;
blink_index    = 1;
userevent_index =1;

%% define structures
saccades = struct('set', 0, ...
                  'start', 0, ...
                  'end', 0, ...
                  'duration', 0, ...
                  'start_location_x', 0, ...
                  'start_location_y', 0, ...
                  'end_location_x', 0, ...
                  'end_location_y', 0, ...
                  'amplitude', 0, ...
                  'peak_speed', 0, ...
                  'peak_speed_at', 0', ...
                  'average_speed', 0, ...
                  'peak_accel', 0, ...
                  'peak_decel', 0, ...
                  'average_accel', 0, ...
                  'index', 0);
              
fixations = struct('set', 0, ...
                   'start', 0, ...
                   'end', 0, ...
                   'duration', 0, ...
                   'location_x', 0, ...
                   'location_y', 0, ...
                   'dispersion_x', 0, ...
                   'dispersion_y', 0, ...
                   'index', 0);

blinks = struct('set', 0, 'start', 0, 'index', 0);

userevents = struct('set', 0, 'start', 0, 'description', '', 'index', 0);

trials = struct('saccades', saccades, ...
                'fixations', fixations, ...
                'blinks', blinks, ...
                'userevents', userevents, ...
                'start', 0, ...
                'end', 0, ...
                'duration', 0, ...
                'filename', filename, ...
                'lookup_table', [], ...
                'separator', separator);
           
empty_trial = trials;
event_types = { 'fixations', 'saccades', 'blinks', 'userevents'} ;

trial_index  = 1;
previous_trial = 1;
event_index = 1;

%% main iterator.
while (feof(file) == false) 
    
    line = fgets(file);
    param_divider = '(\ )|(\t)';  

    line = regexprep(line, param_divider, ' ');
    [event, rest] = strtok(line); 
    
    [obj trial type] = parse_events(event, line, event_index);
    current_trial= trial;
       
    if (isa(obj, 'struct'))
      [separate separator] = trial_separator( separator, obj, type, current_trial, previous_trial );

      if (separate)
         trials(trial_index).end = obj(1).start -1;
         trials(trial_index).duration = trials(trial_index).end - trials(trial_index).start;
         trial_index = trial_index +1;  
         trials(trial_index).start = obj(1).start;
         trials(trial_index) = empty_trial;        
      end;
 
        
        
        items = getfield(trials(trial_index), event_types{type});
        l = length(items);        
        if (getfield(items, 'set') == 0)
            items(1) = obj;
        else
            items(l +1) = obj;
        end;
        trials(trial_index) = setfield(trials(trial_index), event_types{type}, items);       
        trials(trial_index) = set_lookuptable(trials(trial_index), l, event_index, type);
        event_index = event_index + 1;
    
    end;   
    
    previous_trial = current_trial;
end;


%% helper function for parsing single line, and to return a structure.
function[obj set etype] = parse_events(event, line, event_index)
  obj = 0; set = 1; etype = 0;
  event_types = {'Fixation', 'Saccade', 'Blink', 'UserEvent'};
  
  for e = 1:length(event_types)
      type = event_types{e};
      if (strcmp(event, type) && obj == 0)
        [obj set] = parse_type(event_types{e}, line, event_index);
        etype = e;
      end;
  end;         

%% helper function for parsing single line
function[obj set] =  parse_type(type, line, event_index)
  obj = 0; set = 1; 
  
  if (strcmp(type, 'Fixation'))
      [obj set] = parse_fixation_line(line, event_index);
  end;
  if (strcmp(type, 'Saccade'))
      [obj set] = parse_saccade_line(line, event_index);
  end;
  if (strcmp(type, 'Blink'))
      [obj set] = parse_blink_line(line, event_index);
  end;
  if (strcmp(type, 'UserEvent'))
      [obj set] = parse_userevent_line(line, event_index);
  end;

%% switch function for trial index increase
function[ bool separator ] = trial_separator( separator, obj, obj_type, current_trial, previous_trial )
  type = separator.type;
  regular_expression = separator.regular_expression;
  reference_times = separator.reference_times;
  reference_index = min(separator.reference_index, length(reference_times)-1);
  
  bool = false;
  if (strcmp(type, 'message'))
    if (obj_type == 4)
          if (regexp(obj.description, regular_expression))            
               bool = true;
          end
    end;
  elseif (strcmp(type, 'set'))
    bool = (current_trial ~= previous_trial); 
  elseif (strcmp(type, 'time'))
    lowerbound = reference_times(reference_index);
    upperbound = reference_times(reference_index +1);
    starttime = obj.start / 1000; %% convert to seconds
    if ( (starttime > lowerbound) && (starttime < upperbound) )
        bool = false;
    else
        if (starttime < lowerbound)
            bool = false;
        else
            separator.reference_index = reference_index + 1;
            bool = true;
            fprintf('lowerbound : %f\tupperbound : %f\t starttime : %f\n', lowerbound, upperbound, starttime);
    
        end
      end
  end
  
%% helper function for saccade parser
function [ saccade, set ]   = parse_saccade_line ( line, event_index )
  saccade = struct('set', 0, ...
                  'start', 0, ...
                  'end', 0, ...
                  'duration', 0, ...
                  'start_location_x', 0, ...
                  'start_location_y', 0, ...
                  'end_location_x', 0, ...
                  'end_location_y', 0, ...
                  'amplitude', 0, ...
                  'peak_speed', 0, ...
                  'peak_speed_at', 0', ...
                  'average_speed', 0, ...
                  'peak_accel', 0, ...
                  'peak_decel', 0, ...
                  'average_accel', 0, ...
                  'index', event_index);
              
  parts = explode(line, 1);
  saccade.set = parts{3};
  saccade.start = parts{4};
  saccade.end = parts{5};
  saccade.duration = parts{6};
  saccade.start_location_x = parts{7};
  saccade.start_location_y = parts{8};
  saccade.end_location_x = parts{9};
  saccade.end_location_y = parts{10};
  saccade.amplitude = parts{11};
  saccade.peak_speed = parts{12};
  saccade.peak_speed_at = parts{13};
  saccade.average_speed = parts{14};
  saccade.peak_accel = parts{15};
  saccade.peak_decel = parts{16};
  saccade.average_accel = parts{17};

  set = saccade.set;

%% helper function for fixation parser
function [ fixation, set ]  = parse_fixation_line ( line, event_index )
  fixation = struct('set', 0, ...
                  'start', 0, ...
                  'end', 0, ...
                  'duration', 0, ...
                  'location_x', 0, ...
                  'location_y', 0, ...
                  'dispersion_x', 0, ...
                  'dispersion_y', 0, ...
                  'index', event_index);
  parts = explode(line, 1);
  fixation.set = parts{3};
  fixation.start = parts{4};
  fixation.end = parts{5};
  fixation.duration = parts{6};
  fixation.location_x = parts{7};
  fixation.location_y = parts{8};
  fixation.dispersion_x = parts{9};
  fixation.dispersion_y = parts{10};

  set = fixation.set;

%% helper function for userevent parser
function [ userevent, set ] = parse_userevent_line ( line, event_index )
    userevent = struct('set', 0, 'start', 0, 'description', '', 'index', event_index);
    parts = explode(line);
    userevent.set = str2num(parts{2});
    userevent.start = str2num(parts{3});
    l = length(parts);
    userevent.description = strcat(parts{5:l});
    
    set = userevent.set;

%% helper function for blinks
function [ blink, set ]     = parse_blink_line( line, event_index )
   blink = struct('set', 0, 'start', 0, 'index', event_index);
   parts = explode(line, 1);
   blink.set = parts{3};
   blink.start = parts{4};
    
   set = blink.set;
      
   

%% helper function for exploding strings
function [split,numpieces]=explode(string,delimiters)
%EXPLODE    Splits string into pieces.
%   EXPLODE(STRING,DELIMITERS) returns a cell array with the pieces
%   of STRING found between any of the characters in DELIMITERS.
%
%   [SPLIT,NUMPIECES] = EXPLODE(STRING,DELIMITERS) also returns the
%   number of pieces found in STRING.
%
%   Input arguments:
%      STRING - the string to split (string)
%      DELIMITERS - the delimiter characters (string)
%   Output arguments:
%      SPLIT - the split string (cell array), each cell is a piece
%      NUMPIECES - the number of pieces found (integer)
%
%   Example:
%      STRING = 'ab_c,d,e fgh'
%      DELIMITERS = '_,'
%      [SPLIT,NUMPIECES] = EXPLODE(STRING,DELIMITERS)
%      SPLIT = 'ab'    'c'    'd'    'e fgh'
%      NUMPIECES = 4
%
%   See also IMPLODE, STRTOK
%
%   Created: Sara Silva (sara@itqb.unl.pt) - 2002.04.30
if nargin == 1
    delimiters = ' ';
    RETURN_NUMBERS = 0;
else
    if delimiters == 1
        delimiters = ' ';
        RETURN_NUMBERS = 1;
    end
end;

if isempty(string) % empty string, return empty and 0 pieces
   split{1}='';
   numpieces=0;
   
elseif isempty(delimiters) % no delimiters, return whole string in 1 piece
   split{1}=string;
   numpieces=1;
   
else % non-empty string and delimiters, the correct case
   
   remainder=string;
   i=0;
   
	while ~isempty(remainder)
        [piece,remainder]=strtok(remainder,delimiters);
       	i=i+1;
    	if (RETURN_NUMBERS && (i > 2))
            split{i} = str2num(piece);
        else
        	split{i}=piece;
        end;
	end
   numpieces=i;
   
end


function[ filename ] = user_select_file()
    path = FunctionFolder(mfilename);
    cd(path);
    [f, path] = uigetfile({'*.txt; *.dat'},'Choose an ascii-exported IVIEW file');
    if (f == 0)
        error('User aborted');
    end
    filename = [path f];


function[ trial ] = set_lookuptable(trial, type_list_index, event_index, event_type_index)
    trial.lookup_table(event_index,event_type_index) = type_list_index;
    