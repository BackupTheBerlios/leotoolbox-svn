function [a,colnames]=autotextread(fname)
% function [a,colnames]=autotextread(fname)
%
% Read a data file that has a header line, assigning each column
% to a field of a structure with the appropriate name.
%
% For example, if called on this file:
%
% daynum stuff Adjective
% 1  .25 slimy
% 2  .23 speedy
% 3 1.00 super
%
% autotextread will return will return a structure with fields "daynum", "stuff", "company"
% daynum and stuff will be vectors; stuff will be a cell array

% major sections of this code are from
% http://www.mathworks.com/support/solutions/data/26207.shtml

%open file
fid = fopen(fname,'r');
%retrieve column headers
headers = fgetl(fid);
% get a sample data line
samp = fgetl(fid);
%close file
fclose(fid);
%trim possible # or % from header line
if( headers(1) == '#' | headers(1) == '%')
    headers = headers(2:end);
end
% get a cell array of column names
headercell = getvarnames(headers);
% determine type (%f or %s) for each column
ncol = length(headercell);
sampcell = getvarnames(samp);
typestr = [];
for i=1:ncol
    [tmp,ct,errmsg] = sscanf(sampcell{i},'%f');
    if( length(errmsg) > 0 )
        typestr = [typestr, '%s '];
    else
        typestr = [typestr, '%n '];
    end
end
% chop off that last space
typestr = typestr(1:(end-1));

% construct a statement of the form
% [a.col1, a.col2, a.col3 ...] = textread(fname,typestr,'headerlines',1);
% then "eval" it.
evalme = '[';
for i=1:ncol
    evalme = [ evalme, 'a.', headercell{i}, ',' ];
end
evalme = evalme(1:(end-1)); % chop off the last comma
evalme = [evalme '] = textread(fname,typestr,''headerlines'',1,''delimiter'',''\t'');' ];

%evalme

eval(evalme);

%call textread to retrieve the data from your file
%[a,b,c,d,e,f,g] = textread(fname,typestr,'headerlines',1);

%make the names of your variables the names in the header cell array
%eval([headercell{2},' = b'])
%eval([headercell{3},' = c'])
%eval([headercell{4},' = d'])
%eval([headercell{5},' = e'])
%eval([headercell{6},' = f'])
%eval([headercell{7},' = g'])

colnames = headercell;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function names = getvarnames(tempstr)
          %Given a string containing variable names seperated by spaces
          %this function returns a cell array containing each variable name.
          %
          %Written by Megean McDuffy 06/21/00

          ch = char(32); % space
          ch = char(9); % tab
          
          index = 0;
          while length(tempstr > 0)
             
             index = index + 1;
             
             %the fliplr function flips the array left to right  this line of 
             %code will take blanks off of the front and back of the header name 
             tempstr = fliplr(deblank(fliplr(deblank(tempstr))));

             %if its the last variable name
             if isempty(find(tempstr == ch))
               names{index} = tempstr;
               tempstr = [];
             else
               %grab the name
               names{index} = tempstr(1:find(tempstr == ch)-1);
               tempstr(1:find(tempstr == ch)) = [];
             end
             
          end