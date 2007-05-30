function [dacs LUTdacs LUTlums] = lum2dac(lutfile, targetlums, headerlines)

% Date of creation: 7/2/07
% Author: Tony Vladusich

% Say you want to show a stimulus with luminance = 30 cd/m2: what gun drive
% values (dacs) should you use? This function takes a 'look-up table' of
% luminance values measured at different drive values from all three guns
% simultaneously (gray shades). Since the gun values are discrete, and
% luminance values are continuous, we need to 'fill-in' or interpolate all
% intermediate luminance values. This function generates the appropriate
% drive values for any target luminance value within the monitor's range
% (gamut). We cannot display luminance values below 'dark current value':
% when all dacs = 0, as there is still some 'leakage' of light from liquid
% crystal displays (LCDs). We correct for this in a general way by bounding
% target values to lie within the measured range. This introduces errors at
% high and low target luminances, so beware!

% Works for scalars, vectors and matrices: 'lutfile' is the look-up table,
% 'targetlums' is a scalar, vector or matrix of target luminance values,
% and 'headerlines' just tells the function how many lines to skip in your
% input file (default = 3).

% number of headerlines to skip in input file
if ~exist('headerlines', 'var') | isempty(headerlines)
    headerlines = 3;
end

% read in lookup table
LUT = dlmread(lutfile, '', headerlines, 0);

% specifiy dacs (gun drive values, 0 - 255)
LUTdacs = LUT(:, 1);

% specifiy measured luminance values
LUTlums = LUT(:, 11);

% we adjust some target values 'up' and 'down' to the min and max
% displayable luminances
targetlums = max(targetlums, min(LUTlums) + eps);
targetlums = min(targetlums, max(LUTlums));

% interpolate luminance values
dacs = interp1(LUTlums, LUTdacs, targetlums);

% round-off 
dacs = round(dacs);