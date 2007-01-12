function[ parameters ] = present(stim_event, window, wRect, parameters, logfilename, log_pointer, iview_socket, host)
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
    name = stim_event(i).name
    
    %fprintf('stimulus information:\n');
    %fprintf(' - name  : %s\n', stim_event(i).name);
    %fprintf(' - index : %i\n', stim_event(i).index);
    %fprintf(' - duration : %i ms\n\n', stim_event(i).duration);
    %fprintf(' - content : \n');
    %display([stimulus]);
    %fprintf(' - - - - - - - - - - - - - - -\n\n');
   
    tic;
    
    
    nostart_localisation = isempty(strfind(name, 'localisation stimulus 1'));
    nostart_stimulusblock = isempty(strfind(name, 'starting stimulus'));
    if ( nostart_stimulusblock ~= 1 || nostart_localisation ~= 1)
        wait_for_scanner(log_pointer);
    end

    text = ['presenting ' name];
    log(text, log_pointer); 
    remark_command = ['ET_REM "' text ' - name: ' name '"' ];
    iview_send(iview_socket, remark_command, host);
    
    parameters = present(stimulus, duration /   1000, window, wRect, parameters, log_pointer);

    increment_set = 'ET_INC';
    iview_send(iview_socket, increment_set, host);

    stop_recording = ['ET_PSE'];
    iview_send(iview_socket, stop_recording, host);

    save_command = ['ET_SAV "D:\JanBernard\housesfaces\' logfilename '-' num2str(i) '.idf"' ];
    iview_send(iview_socket, save_command, host);

    continue_recording = ['ET_CNT'];
    iview_send(iview_socket, continue_recording, host);

    toc
end;
