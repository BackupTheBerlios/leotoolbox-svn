function c = set(stimulus, varargin)
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

if (class(picture) ~= 'picture')
    msg = ['Invalid class : class of type picture required.\nFound class type : ' class(picture)];
    error(msg);
end
   
c = stimulus;
if length(propertyArgIn) == 2,

   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   
   switch prop
   case 'data'
      assertClass(val);
      c.data = val;
      c.type = class(val);
   otherwise
      error('Asset properties: data');
   end;

end

  %nested functions for assertion 
  function b = assertClass ( obj )
    switch class(obj)
      case 'picture'
        b = true;
      otherwise
        b = false; 
        error('This function has not been implemented yet. Try feeding pictures');
    end;     
  end;

end