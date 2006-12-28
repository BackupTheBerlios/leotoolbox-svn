function b=brownianNoise(x, y)

% returns an image consisting of brownian noise

if ~exist('x', 'var') | isempty(x)
    error('Need at least one dimension, usage: b=brownianNoise(x [, y])');
end

if ~exist('y', 'var') | isempty(y)
    y=x;
end

b=spatialPattern([x y],-2);