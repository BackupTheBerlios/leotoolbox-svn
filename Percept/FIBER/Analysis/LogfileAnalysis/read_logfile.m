function[ data filename ] = read_logfile(filename)

if nargin == 0
    [file path] = uigetfile({'*.txt; *.*'},'Choose an experiment logfile');
    filename = [path file];
end    

fp = fopen(filename, 'r');

i = 1;
while (~(feof(fp)))

    line = fgets(fp);
    
    parts = explode(line, sprintf('\t'));
    data(i, 1:length(parts)) = parts;
    i = i +1;

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
    RETURN_NUMBERS = 1;
    if delimiters == 1
        delimiters = ' ';
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
            if (isempty(split{i}))
                split{i} = piece;
            end
        else
        	split{i}=piece;
        end;
	end
   numpieces=i;
   
end
