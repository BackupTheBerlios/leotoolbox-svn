function display(stimulus)
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

for s = 1: size(stimulus, 2)
    
  fprintf('stimulus_event information:\n');
  fprintf(' - name  : %s\n', stimulus(s).name);
  fprintf(' - index : %i\n', stimulus(s).index);
  fprintf(' - duration : %i ms\n\n', stimulus(s).duration);
  fprintf(' - content : \n');
  
  
  display([stimulus(s).stimulus]);
  
  fprintf(' - - - - - - - - - - - - - - -\n\n');
end