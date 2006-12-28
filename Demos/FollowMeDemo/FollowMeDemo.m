% 080105 fwc simple demo based on a question posted on ptb mailinglist.
% 281206 fwc some changes, requires WaitSetMouse function from
% PsychUtilities
%                   

clear all;
try
    fprintf('%s, move mouse to see demo, press any key or mousebutton to quit\n\n\t', mfilename);

    screenNumber=max(Screen('Screens'));
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);
    red=[255 0 0];
    % Open a double buffered fullscreen window and draw a gray background
    % and front and back buffers.
    [w, screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    Screen('FillRect',w, gray);
    Screen('Flip', w);
    targetRect=CenterRect(screenRect/3, screenRect);
    dotRect=[0 0 20 20];
    smallDotRect=[0 0 3 3];
    HideCursor;
    [x,y]=WindowCenter(w);
    WaitSetMouse(x,y, w); % function from PsychUtilities
    while KbCheck; end
    while 1
        [x,y, buttons] = GetMouse(w);

        Screen('FrameRect',w, black, targetRect);

        if 1==IsInRect(x,y,targetRect)
            rect = CenterRectOnPoint(dotRect, x, y);
            Screen('FillOval',w, red, rect);
        else
            rect = CenterRectOnPoint(smallDotRect, x, y);
            Screen('FillOval',w, white, rect);
        end
        Screen('Flip', w);
        if KbCheck
            break;
        end
        if any(buttons)
            break;
        end
    end

    ShowCursor;
    Screen('CloseAll');
    fprintf('\nEnd of %s.\n', mfilename);
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..


