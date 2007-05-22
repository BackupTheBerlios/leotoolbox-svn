function[stimulus] = calculate_next_stimulus(stimuli, parameterlist)
%
% return the stimulus based on the parameters of the experiment
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

s = size(stimuli, 2);
s
number = 1+ floor(rand(1, 1) * (size(stimuli, 2) -1))
stimulus = stimuli(number)