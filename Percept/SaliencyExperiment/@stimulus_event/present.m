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
%  09/12/2006    Created
%  12/01/2007    Adapted for fMRI course experiment
first_time_trigger = true;

for i=1:size(stim_event, 2)
    stimulus = stim_event(i).stimulus;
    single_duration = stim_event(i).duration;
    name = stim_event(i).name;
    
    if (i == 2)
        first_time_trigger = false;
    end;
        
    percentage = round( duration(stim_event(1:i)) / duration(stim_event) * 100);
    status1 = ['stimulus ' num2str(i) ' of ' num2str(size(stim_event, 2)) '\n'];
    status2 = ['Percentage completed : ' num2str(percentage) ' percent\n'];
    fprintf(status1);
    fprintf(status2);
    
    nostart_localisation  = isempty(strfind(name, 'localisation stimulus 1'));
    nostart_stimulusblock = isempty(strfind(name, 'starting stimulus'));
 
    if ( nostart_stimulusblock ~= 1 || nostart_localisation ~= 1)
        if (first_time_trigger == false)
            first_time_trigger = false;
            wait_for_scanner(log_pointer);
        end;
    end

    
    text = ['presenting ' name];
    log(text, log_pointer); 
    remark_command = ['ET_REM "' text ' - name: ' name '"' ];
    iview_send(iview_socket, remark_command, host);

    tic;    
    parameters = present(stimulus, single_duration /   1000, window, wRect, parameters, log_pointer);

    %% Increment set, set of eyedata per stimulus.
    increment_set = 'ET_INC';
    iview_send(iview_socket, increment_set, host);

    %% Backup file on eyetracker operator PC
    stop_recording = ['ET_PSE'];
    iview_send(iview_socket, stop_recording, host);

    save_command = ['ET_SAV "D:\JanBernard\housesfaces\' logfilename '-' num2str(i) '.idf"' ];
    iview_send(iview_socket, save_command, host);

    continue_recording = ['ET_CNT'];
    iview_send(iview_socket, continue_recording, host);

    toc
end;
