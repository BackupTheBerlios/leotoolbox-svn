function stimuli = create_stimuli( images )
%
% Create the screens containing images or other features
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

for i=1:size(images ,2)
    
    s = stimulus;    
    stimuli(i) = set(s, 'data', images(i));
    
end;   