function p = set(bitmap, varargin)

propertyArgIn = varargin;

if (class(bitmap) ~= 'bitmap')
    msg = ['Invalid class : class of type bitmap required.\nFound class type : ' class(stimulus)];
    error(msg);
end
    
while length(propertyArgIn) >= 2,

   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   switch prop
   case 'filename'
      bitmap.filename = val;
   case 'path'
      bitmap.path = val;
   case 'name'
       bitmap.name= val;
   case 'parameters'
       bitmap.parameters = val;
   case 'data' 
       bitmap.data = val;
   otherwise,
      error('Asset properties: filename, name, path, data, parameters, category')
   end
end

p = bitmap;
