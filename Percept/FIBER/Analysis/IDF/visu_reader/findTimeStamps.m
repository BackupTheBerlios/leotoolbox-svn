function line = findTimeStamps(timeStamps, theTimes, timeColumn)

% function line = findTimeStamps(timeStamps, theTimes, timeColumn)
%
% returns the line numbers or NaN if not found
% e.g.: findTimeStamps(data, [1 3 4], 1);

% Oliver Lindemann, 09.01.2002

if nargin<3
   timeColumn = 1;
end;

if min(size(timeStamps))==1
    timeStamps = timeStamps(:); % force column 
end

line =[];
for i=1:length(theTimes)
   tmp = min( find( timeStamps(:, timeColumn)>= theTimes(i) ) );
   if isempty(tmp)
      tmp= NaN;
   end 
   line = [line tmp];
end

