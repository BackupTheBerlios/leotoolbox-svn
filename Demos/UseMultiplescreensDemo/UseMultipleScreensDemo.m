% simple demo showing how to open and display stuff on multiple windows
% fwc 281206

clear all;
commandwindow;
try
    fprintf('At the end of %s, press any key to quit\n\n\t', mfilename);
    
    screens=Screen('Screens'); % vector with valid screen numbers, main is 0
    % Open a double buffered fullscreen window  on each attached screen
    % and draw a gray background with a coloured text on it

    for screenNumber=screens
        i=screenNumber+1;
        fprintf('Opening window on screen #%d\n', screenNumber);
        [w(i) sRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
        white=WhiteIndex(w(i));
        black=BlackIndex(w(i));
        gray=GrayIndex(w(i));
        
        % not defining some values hangs the program
        Screen('TextFont',w(i), 'Courier');
        Screen('TextSize',w(i), 100);
        Screen('TextStyle', w(i), 0);

        [x,y] = RectCenter(sRect);
        Screen('FillRect',w(i), gray);
        Screen('DrawText',w(i), ['Screen #' num2str(i-1)],x-300,y,[255*rand(1,3)]);
        Screen('Flip', w(i));
    end

    while KbCheck; end
    tEnd=GetSecs+3;
    while ~KbCheck & GetSecs<tEnd; end
    Screen('CloseAll');
    fprintf('\nEnd of %s\n', mfilename);

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..


