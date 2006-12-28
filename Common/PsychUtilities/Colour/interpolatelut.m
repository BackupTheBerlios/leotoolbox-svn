function [newlut, newdac]=interpolatelut(oldlut, olddac, polyorder)

% USAGE: newlut=interpolatelut(oldlut, olddac [, polyorder])
% we take a lut file and fit a polynomial to the data.
% we then expand the LUT file to a stepsize of 1.
% default order of polynomial is 3, set polyorder for a different fit
% olddac is list of dac values at which oldlut was measured.
% Note: we correct for any unwanted increases at low dac values

% comments to Frans W. Cornelissen, email: f.w.cornelissen@med.rug.nl

% History
% 16-02-04  fwc first version, based on a routine from Minolta toolbox


if ~exist('order', 'var') | isempty(order)
    polyorder=3;
end

newdac=0:max(olddac);  % one entry for each dac value, we do not extrapolate beyond first and last measured value

[entries, channels]=size(oldlut);

for i=1:channels
    [p,s] = polyfit(olddac,oldlut(:,i), polyorder);
    newlut(:,i)=polyval(p, newdac)';
end

% newlut

[entries, channels]=size(newlut);

% correct for any unwanted increases (at low dac values)
for c=1:channels
    for r=entries-1:-1:1
        if newlut(r+1,c) < newlut(r,c) | newlut(r,c) < oldlut(1,c)
            % replace data by linearly extrapolating between previous value and first measured value
            newlut(1:r+1,c)=linspace(oldlut(1,c), newlut(r+1,c), r+1)';	
            break;
        end
    end
end

% [entries, channels]=size(newlut)
