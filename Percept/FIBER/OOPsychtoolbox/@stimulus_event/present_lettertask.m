
function[ parameters ] = present_lettertask(stim_event, window, wRect, parameters, log_pointer, iview_socket, host)
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
eight_letters = random_eight_letters;
old_letters = eight_letters;

assignin('base', 'start', GetSecs);
for i=1:size(stim_event, 2)
    
    if (stim_event(i).wait_for_trigger_before)
        wait_for_scanner(log_pointer);
    end;
    
    stimulus = stim_event(i).stimulus;
    single_duration = stim_event(i).duration; 
    name = stim_event(i).name;
    
        
    percentage = round( duration(stim_event(1:i)) / duration(stim_event) * 100);
    status1 = ['stimulus ' num2str(i) ' of ' num2str(size(stim_event, 2)) '\n'];
    status2 = ['Percentage completed : ' num2str(percentage) ' percent\n'];
    fprintf(status1);
    fprintf(status2);         
    
    text = ['starting to display ' name];   
    log(text, log_pointer);  %% log to matlab file
    remark_command = ['ET_REM "' text ' - name: ' name '"' ];
    iview_send(iview_socket, remark_command, host); %% log to idf file
    
    if (stim_event(i).driftcorrection > 0)
        timing = stim_event(i).driftcorrection;
        parameters = present_lettertask(stimulus, timing /   1000, window, wRect, parameters, log_pointer);
        fprintf('Performing drift correction @ %d ms.', timing);
       
        stop_recording = ['ET_PSE'];
        iview_send(iview_socket, stop_recording, host);
        
        dc = 'ET_RCL';
        iview_send(iview_socket, dc, host);       
        
        continue_recording = ['ET_CNT'];
        iview_send(iview_socket, continue_recording, host);

        [eight_letters old_letters] = present_lettertask(stimulus, (single_duration - timing) /   1000, window, wRect, parameters, log_pointer, eight_letters, old_letters);
    else
        [eight_letters old_letters] = present_lettertask(stimulus, single_duration /   1000, window, wRect, parameters, log_pointer, eight_letters, old_letters);
    end
        
    text = ['ending to display ' name];
    log(text, log_pointer);
    
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
    
    %% Increment set, set of eyedata per stimulus.
    increment_set = 'ET_INC';
    iview_send(iview_socket, increment_set, host);

    %% Backup file on eyetracker operator PC
    stop_recording = ['ET_PSE'];
    iview_send(iview_socket, stop_recording, host);

    save_command = ['ET_SAV "D:\JanBernard\housesfaces3\' idf_file '-' num2str(i) '.idf"' ];
    iview_send(iview_socket, save_command, host);

    continue_recording = ['ET_CNT'];
    iview_send(iview_socket, continue_recording, host);
    

end;
