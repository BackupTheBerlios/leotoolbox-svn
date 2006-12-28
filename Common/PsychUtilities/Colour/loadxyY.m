function [xyY, dac]=loadxyY(xyYfile, extension, headerlines)

% load text file with CIE xyY look-up table values
% USAGE: [xyY, dac]=loadLuts(xyYfile [, extension, headerlines])
% 
% comments to Frans W. Cornelissen, email: f.w.cornelissen@med.rug.nl

% History
% 05-02-04  fwc first version
% 09-02-04  FWC subtract dark current from all readings. Return best estimate of actual dark
%               current (mean of all channels at 0)
% 10-02-04  fwc now reads in xyY data for all channels, other stuff done
%               outside this routine for maximum flexibility

% default extension is .txt
if ~exist('extension', 'var') | isempty(extension)
    extension='.txt';
end

% default number of headerlines is 1
if ~exist('headerlines', 'var') | isempty(headerlines)
    headerlines=1;
end


% read in lookup table file into single matrix
if strcmp( computer, 'MAC')==1  % for PC as well?
    [myxyY]=Textread([xyYfile extension], '', 'delimiter','\t', 'headerlines', headerlines);
else % workaround for OS 9 version of textread
    [myxyY(:,1),myxyY(:,2),myxyY(:,3),myxyY(:,4),myxyY(:,5),myxyY(:,6),myxyY(:,7), ...
            myxyY(:,8), myxyY(:,9), myxyY(:,10), myxyY(:,11), myxyY(:,12), myxyY(:,13)]= ...
            textread([xyYfile extension], ...
            '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f', 'headerlines', headerlines);
end 

dac=myxyY(:,1); % dac values for which lut values are given
myxyY=myxyY(:,2:end);

% create a single variable, with channels as a variable
for c=1:4 % channels R,G,B, Gray/White
    for i=1:3 % cie x, y, Y
        xyY(c,:,i)=myxyY(:,i+(c-1)*3);
    end
end

return;
