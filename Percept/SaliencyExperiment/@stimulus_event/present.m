function[ parameters ] = present(stim_event, window, wRect, parameters)
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
%  9/12/2006    Created

for i=1:size(stim_event, 2)
    stimulus = stim_event(i).stimulus;
    
    duration = stim_event(i).duration;
    fprintf('stimulus information:\n');
    fprintf(' - name  : %s\n', stim_event(i).name);
    fprintf(' - index : %i\n', stim_event(i).index);
    fprintf(' - duration : %i ms\n\n', stim_event(i).duration);
    fprintf(' - content : \n');
    display([stimulus]);
    fprintf(' - - - - - - - - - - - - - - -\n\n');

    parameters = present(stimulus, duration /   1000, window, wRect, parameters);
end;
