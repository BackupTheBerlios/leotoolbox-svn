function c = picture( varargin )


c.elements = [];

% relative coordinates to center
c.locations = [];
c.locationtypes = [];
c.description = [];


c = class(c, 'picture');

if (~isempty(varargin))

    for i=1:size(varargin)
        bs = varargin{i};
        for j=1:size(bs, 2)
          b = bs(j);
          c = add(picture, 'bitmap', b);
        end;
    end;
end;