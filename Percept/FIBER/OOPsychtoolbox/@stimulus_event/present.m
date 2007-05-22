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
%  09/12/2006    Created
%  12/01/2007    Adapted for fMRI course experiment
%  16/04/2007    Trigger fields added, so you can add 'wait for trigger'
%                around stimuli

idf_file = [ datestr(now,'yyyymmdd-HHMM') '.idf'];

for i=1:size(stim_event, 2)
    
    if (stim_event(i).wait_for_trigger_before)
        wait_for_scanner(log_pointer);
    end;
    
    stimulus = stim_event(i).stimulus;
    single_duration = stim_event(i).duration; 
    name = stim_event(i).name;
    
    time1 = duration(stim_event(1:i));
    time2 = duration(stim_event);
    percentage = round( time1 / time2 * 100);
    status1 = ['stimulus ' num2str(i) ' of ' num2str(size(stim_event, 2))];
    status2 = [' (' num2str(percentage) ' %%)\n'];
    fprintf(status1);
    fprintf(status2);         
    
    text = ['starting to display ' name ' (duration : ' num2str(stim_event(i).duration) ') time : ' num2str(GetSecs)];   
    mlog(text, log_pointer);  %% log to matlab file

    text = ['starting to display :' name '(duration : ' num2str(stim_event(i).duration) ];  
    
    remark_command = ['ET_REM "' text '"' ];
    iview_send(iview_socket, remark_command, host); %% log to idf file
 
    %% Increment set, set of eyedata per stimulus.
    increment_set = 'ET_INC';
    iview_send(iview_socket, increment_set, host);

    if (stim_event(i).driftcorrection > 0)
        timing = stim_event(i).driftcorrection;
        parameters = present(stimulus, timing /   1000, window, wRect, parameters, log_pointer);
        drifttext = sprintf('Performing drift correction @ %d ms.\n', timing);
        mlog(drifttext, log_pointer);
        
        stop_recording = ['ET_PSE'];
        iview_send(iview_socket, stop_recording, host);
        
        dc = 'ET_RCL';
        iview_send(iview_socket, dc, host);       
        
        continue_recording = ['ET_CNT'];
        iview_send(iview_socket, continue_recording, host);

        parameters = present(stimulus, (single_duration - timing) /   1000, window, wRect, parameters, log_pointer);        
    else        
        parameters = present(stimulus, single_duration /   1000, window, wRect, parameters, log_pointer);
    end
        
    text = ['ending to display ' name];
    mlog(text, log_pointer);
    
    if (stim_event(i).wait_for_trigger_after)
        wait_for_scanner(log_pointer);
    end;
   
    if i < 10
        t = ['0' num2str(i +1)];
    else
        t = num2str(i + 1);
    end;
                
    %% offscreen = Screen(window, 'GetImage');
    %% filename = [t '-run2-' name '-' num2str(i) '.jpg'];
    %% imwrite(offscreen, filename, 'JPG');
    

    %% Backup file on eyetracker operator PC
    stop_recording = ['ET_PSE'];
    iview_send(iview_socket, stop_recording, host);    

    save_command = ['ET_SAV "D:\JanBernard\housesfaces3\' idf_file '-' num2str(i) '.idf"' ];
    iview_send(iview_socket, save_command, host);

    continue_recording = ['ET_CNT'];
    iview_send(iview_socket, continue_recording, host);
    

end;
