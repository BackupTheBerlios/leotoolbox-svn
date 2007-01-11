function[ parameters ] = present(stim_event, window, wRect, parameters, log_pointer, iview_socket, host)
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
    name = stim_event(i).name;
    
    %fprintf('stimulus information:\n');
    %fprintf(' - name  : %s\n', stim_event(i).name);
    %fprintf(' - index : %i\n', stim_event(i).index);
    %fprintf(' - duration : %i ms\n\n', stim_event(i).duration);
    %fprintf(' - content : \n');
    %display([stimulus]);
    %fprintf(' - - - - - - - - - - - - - - -\n\n');
   
    tic;
    text = ['presenting stimulus ' num2str(i)];
    log(text, log_pointer); 
    
    remark_command = ['ET_REM "' text ' - name: ' name '"' ];
    iview_send(iview_socket, remark_command, host);

    parameters = present(stimulus, duration /   1000, window, wRect, parameters, log_pointer);

    increment_set = 'ET_INC';
    iview_send(iview_socket, increment_set, host);
    
    toc
end;
