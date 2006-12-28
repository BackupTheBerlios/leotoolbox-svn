function p=pinkNoise(x, y)

% returns an image consisting of pink noise

if ~exist('x', 'var') | isempty(x)
    error('Need at least one dimension, usage: p=pinkNoise(x [, y])');
end

if ~exist('y', 'var') | isempty(y)
    y=x;
end

p=spatialPattern([x y],-1);