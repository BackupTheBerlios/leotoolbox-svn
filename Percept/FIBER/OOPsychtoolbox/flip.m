function[] = flip( window, log_pointer, description )


    [v s f m b] = Screen('Flip', window);    
    event = ['Screen flip @ ' num2str(s)];

 if (log_pointer > 0)   
    mlog(event, log_pointer);
 else
     fprintf(['Could not write to log : ' event '\n']);
 end
    