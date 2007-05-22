function s = get( picture, propName ) 
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
    

switch propName
    case 'description'
        s = picture.description;
    case 'elements'        
        s = picture.elements;
    case 'elementtypes'        
        s = picture.elementtypes;
    case 'locations'
        s = picture.locations;
    case 'alphas'
        s = picture.alphas;
    otherwise error('No such property');
end;