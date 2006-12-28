function n=noise(x, y, d)

% returns an image consisting of spectral noise.
% defaults to pink noise (d=-1)

if ~exist('x', 'var') | isempty(x)
    error('Need at least one dimension, usage: n=noise(x [, y, d])');
end

if ~exist('y', 'var') | isempty(y)
    y=x;
end

if ~exist('d', 'var') | isempty(d)
    d=-1; % pink noise
end

n=spatialPattern([x y],d);