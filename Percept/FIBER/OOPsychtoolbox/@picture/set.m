function c = set(picture, varargin)
%
%
%
%

propertyArgIn = varargin;

if (class(picture) ~= 'picture')
    msg = ['Invalid class : class of type picture required.\nFound class type : ' class(picture)];
    error(msg);
end
c = picture;

while length(propertyArgIn) >= 3,

   prop = propertyArgIn{1};
   idx = propertyArgIn{2};
   val = propertyArgIn{3};
   propertyArgIn = propertyArgIn(4:end);

   switch prop
   case 'description'
      c.description = val;
   case 'element'
      c.elements(idx) = val;
   case 'location'
      c.location = val;
   case 'alphas'
      c.alphas = val 
   otherwise
      error('Asset properties: description, elements')
   end
end
