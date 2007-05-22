function[timings] = extract_localiser_timings

[file path] = uigetfile;

fp = fopen([path file], 'r');

block_flag = false;

timings = struct('start', 0, 'end', 0, 'description', '');
timing_index = 1;

line = fgets(fp); % get header
    
while ~(feof(fp))
   
    line = fgets(fp);
    
    parts = explode(line, sprintf('\t'));
    
    description = parts{5};
    
    if (~isempty(strfind(description, 'starting')))
        if block_flag == false
            block_flag = true;
            if ~isempty(strfind(description, 'face'))
                timings(timing_index).start = str2num(parts{4});
                timings(timing_index).description = 'face';
            end
        
            if ~isempty(strfind(description, 'house'))
                timings(timing_index).start = str2num(parts{4});
                timings(timing_index).description = 'house';
            end
    
            if ~isempty(strfind(description, 'fixation'))
                timings(timing_index).end = last_ending;
                timing_index = timing_index + 1;
                block_flag = false;
                timings(timing_index).start = str2num(parts{4});
                timings(timing_index).description = 'fixation';          
            end
        end
    end
    if ~isempty(strfind(description, 'ending'))
        if ~isempty(strfind(description, 'face'))
            timings(timing_index).description = 'face';
            last_ending = str2num(parts{4});
        end
        if ~isempty(strfind(description, 'house'))
            timings(timing_index).description = 'house';
            last_ending = str2num(parts{4});
        end
        if ~isempty((strfind(description, 'fixation')))
            timings(timing_index).end = str2num(parts{4});
            timing_index = timing_index + 1;
            block_flag = false;
        end            
        
    end
    

end



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
    end
    RETURN_NUMBERS = 0;
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

