function[b] = isImage(filename)
%
%  Checks whether the given filename is an image
%  The array of images is [ jpg jpeg tiff gif bmp ] 
%
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

  imagetypes = ['.jpg' '.jpeg' '.tiff' '.gif' '.bmp'];
  
  length = size(filename, 2);
  try
      currentType  = filename(length -3:length);
  catch
      fprintf('Index out of bounds');
  end;
  
  r = strfind(imagetypes, currentType);
  b = ~isempty(r);
