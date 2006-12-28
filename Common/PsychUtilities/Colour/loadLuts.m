function [luts, dark, dac]=loadluts(lutfile, extension, headerlines)

% load text file with look-up table values
% USAGE: [luts, dark, dac]=loadLuts(lutfile [, extension, headerlines])
% 
% comments to Frans W. Cornelissen, email: f.w.cornelissen@med.rug.nl

% History
% 05-02-04  fwc first version
% 09-02-04  FWC subtract dark current from all readings. Return best estimate of actual dark
%               current (mean of all channels at 0)

% default extension is .txt
if ~exist('extension', 'var') | isempty(extension)
    extension='.txt';
end

% default number of headerlines is 1
if ~exist('headerlines', 'var') | isempty(headerlines)
    headerlines=1;
end

% read in lookup table file into single matrix
if strcmp( computer, 'MAC')==1
    [luts]=textread([lutfile extension], '', 'delimiter','\t', 'headerlines', headerlines);
else % workaround for OS 9 version of textread
    [luts(:,1),luts(:,2),luts(:,3),luts(:,4),luts(:,5)]= ...
        textread([lutfile extension], '%f\t%f\t%f\t%f\t%f', 'headerlines', headerlines);
end

dac=luts(:,1);  % dac values at which lut values are given
dark=mean(luts(1,2:end)); % calculate best estimate of dark current
[r,c]=size(luts);
luts=luts(:,2:end)-repmat(squeeze(luts(1,2:end)),r,1); % actual luts, subtract dark current values