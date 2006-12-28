clear all;
myimgfile='konijntjes1024x768.jpg';
wtime=5;

try
    commandwindow;
    fprintf('simple OSX img demo\n\n\t');
    fprintf('At the end of the demo,\n press any key to quit\nor wait for %.1f secs.\n\t', wtime);
    
    if ~exist(myimgfile,'file')
          fprintf('Can''t find the img file ''%s''.\nPlease make sure it is in the directory ''%s''.\n', myimgfile, pwd);
          return
    end
    
    if 0 Screen('Preference', 'SkipSyncTests', 1); end % since it's only a demo ...
    AssertOpenGL;

    screenNumber=max(Screen('Screens'));
    [w, screenRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
    gray=GrayIndex(screenNumber);
    drect=CenterRect(screenRect/2, screenRect);
    Screen('FillRect',w, gray);

    Screen('PutImage', w, imread(myimgfile, 'jpg'), drect );
    Screen('Flip',w);
    while KbCheck; end
    tEnd=GetSecs+wtime;
    while ~KbCheck & GetSecs<tEnd; end % wait max for 5 secs for a key press
    Screen('CloseAll');
    fprintf('\nEnd of demo.\n');
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    commandwindow;
    rethrow(lasterror);
end %try..catch..


