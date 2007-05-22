function[] = pauseScreen()

screennumber = max(Screen('Screens'));
Screen('Preference','SkipSyncTests', 0);
[window, wRect] = Screen('OpenWindow', screennumber);

Screen('DrawText', window, '+');
Screen('FillRect', window, 0);
Screen('Flip', window);

