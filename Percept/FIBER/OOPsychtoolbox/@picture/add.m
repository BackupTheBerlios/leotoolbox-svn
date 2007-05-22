function c = add(picture, varargin)
%
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

propertyArgIn = varargin;

if (class(picture) ~= 'content')
    msg = ['Invalid class : class of type picture required.\nFound class type : ' class(picture)];
    error(msg);
end
c = picture;    

while length(propertyArgIn) >= 2,

   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   
   switch prop
    
   case 'text'
      idx = size(c.elements, 2) + 1;
      c.elements{idx} = val;
      c.locations{idx} = [0 0];
      c.locationtypes{idx} = 'abs';
      c.alphas{idx} = 1;
      c.fontsizes{idx} = 24;
   case 'bitmap'
      idx= size(c.elements, 2 ) +1; 
      c.elements{idx} = val;
      c.locations{idx} = [0 0];
      c.locationtypes{idx} = 'rel';
      c.alphas{idx} = 1;
      c.fontsizes{idx} = 24;

   case 'elementtype'
      idx= size(c.elements, 2 ); 
      c.elementtypes{idx} = val;      
   
   case 'location'
      idx = size(c.elements,2 );
      c.locations{idx} = val;
      c.locationtypes{idx} = 'abs';
      
   case 'alpha'
      idx = size(c.elements,2 );
      c.alphas{idx} = val;
   
   case 'position'
      idx = size(c.elements,2 );
      c.locationtypes{idx} = val; 
   case 'fontsize'
      idx = size(c.elements,2 );
      c.fontsizes{idx} = val;
      
   otherwise
      error('Possibilities to add : bitmap / text');
   end;
end
