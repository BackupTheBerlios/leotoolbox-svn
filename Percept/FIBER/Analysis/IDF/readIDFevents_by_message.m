function[ trials ] = readIDFevents_by_message( filename )
%% IDF Event reader
%
% INPUT : filename of exported IDF file
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

%          trial(x).userevents : structure-array of saccades, each
%                                containing the following fields
%
%          trial(x).start      : starttime of first event found in trial(x)
%          trial(x).end        : endtime of last event found in trial(x)
%          trial(x).duration   : trial(x).end - trial(x).start
%
%          trials.filename     : read filename   
if nargin ==0
    cd '/Users/marsman/Documents/Programming/Matlab/leotoolbox/Percept/IDF/sample';
    [f, path] = uigetfile({'*.txt; *.dat'},'Choose an ascii-exported IVIEW file');
    filename = [path f];
end

file = fopen(filename, 'r');
              
d_index = 1;

assignin('base', 'file', file);

fixation_index = 1;
saccade_index  = 1;
blink_index    = 1;
userevent_index =1;


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
                  'average_accel', 0);
              
fixations = struct('set', 0, ...
                   'start', 0, ...
                   'end', 0, ...
                   'duration', 0, ...
                   'location_x', 0, ...
                   'location_y', 0, ...
                   'dispersion_x', 0, ...
                   'dispersion_y', 0);

blinks = struct('set', 0, 'start', 0);

userevents = struct('set', 0, 'start', 0, 'description', '');

trials = struct('saccades', saccades, 'fixations', fixations, 'blinks', blinks, 'userevents', userevents, 'start', 0, 'end', 0, 'duration', 0, 'filename', filename);
empty_trial = trials;
event_types = { 'fixations', 'saccades', 'blinks', 'userevents'} ;

trial_index  = 1;
previous_trial = 1;

%%
while (feof(file) == false) 
    
    line = fgets(file);
    param_divider = '(\ )|(\t)';  

    line = regexprep(line, param_divider, ' ');
    [event, rest] = strtok(line); 
    
    [obj trial type] = parse_events(event, line);
    current_trial= trial;
 
    if type == 4 %% event isa userevent

        if (regexp(obj.description, 'Message'))            
             trials(trial_index).end = obj.start -1;
             trials(trial_index).duration = trials(trial_index).end - trials(trial_index).start;
             trial_index = trial_index +1;  
             trials(trial_index) = empty_trial;        
             trials(trial_index).start = obj.start;
        end
    end

    %%if (current_trial ~= previous_trial)
    %%    trial_index = trial_index +1;  
    %%    trials(trial_index) = empty_trial;        
    %%end;
    
    if (isa(obj, 'struct'))
        items = getfield(trials(trial_index), event_types{type});
        l = length(items);        
        if (getfield(items, 'set') == 0) %% check whether we just increased trial_set
            % trials(trial_index).start = obj(1).start;
            % if (trial_index > 1)
            %     trials(trial_index - 1).end = obj(1).start -1;
            %     trials(trial_index - 1).duration = trials(trial_index - 1).end - trials(trial_index - 1).start;
            % end;
            items(1) = obj;
        else
            items(l +1) = obj;
        end;
        trials(trial_index) = setfield(trials(trial_index), event_types{type}, items);       
    end;
        
    previous_trial = current_trial;
end;


%% 
function[obj set etype] = parse_events(event, line)
  obj = 0; set = 1; etype = 0;
  event_types = {'Fixation', 'Saccade', 'Blink', 'UserEvent'};
  
  for e = 1:length(event_types)
      type = event_types{e};
      if (strcmp(event, type) && obj == 0)
        [obj set] = parse_type(event_types{e}, line);
        etype = e;
      end;
  end;         

%%
function[obj set] =  parse_type(type, line)
  obj = 0; set = 1; 
  
  if (strcmp(type, 'Fixation'))
      [obj set] = parse_fixation_line(line);
  end;
  if (strcmp(type, 'Saccade'))
      [obj set] = parse_saccade_line(line);
  end;
  if (strcmp(type, 'Blink'))
      [obj set] = parse_blink_line(line);
  end;
  if (strcmp(type, 'UserEvent'))
      [obj set] = parse_userevent_line(line);
  end;




%%
function [ saccade, set ]   = parse_saccade_line ( line )
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
                  'average_accel', 0);
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
%%
function [ fixation, set ]  = parse_fixation_line ( line )
  fixation = struct('set', 0, ...
                  'start', 0, ...
                  'end', 0, ...
                  'duration', 0, ...
                  'location_x', 0, ...
                  'location_y', 0, ...
                  'dispersion_x', 0, ...
                  'dispersion_y', 0);
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
%%
function [ userevent, set ] = parse_userevent_line ( line )
    userevent = struct('set', 0, 'start', 0, 'description', '');
    parts = explode(line);
    userevent.set = str2num(parts{2});
    userevent.start = str2num(parts{3});
    l = length(parts);
    userevent.description = strcat(parts{5:l});
    
    set = userevent.set;
%%    
function [ blink, set ]     = parse_blink_line( line )
   blink = struct('set', 0, 'start', 0);
   parts = explode(line, 1);
   blink.set = parts{3};
   blink.start = parts{4};
    
   set = blink.set;
   
   
   

%%explode
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
