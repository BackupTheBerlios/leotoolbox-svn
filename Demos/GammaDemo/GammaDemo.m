clear all;
commandwindow;

AssertOSX;
% try
if 1 Screen('Preference', 'SkipSyncTests', 1); end

fprintf('OSX Gamma Example\n\n\t');

screenNumber=max(Screen('Screens'));
[window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


gTab=Screen('ReadNormalizedGammaTable', window);


gTab;


% Find the color values which correspond to white and black.  Though on OS
% X we currently only support true color and thus, for scalar color
% arguments,
% black is always 0 and white 255, this rule is not true on other platforms will
% not remain true on OS X after we add other color depth modes.
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=GrayIndex(screenNumber);

inc=white-gray;

[width, height]=Screen('WindowSize', window);

% draw some rectangeles.
% large number for testing on lcd screen
% use small number (4-10) to determine

c=128;

rect=[ 0 0 200 200];
rect=CenterRectInWindow(rect, window);

size(gTab)

WaitSecs(.1);

stop=0;

stopKey=KbName('escape');
nextKey=KbName('space');

upKey=KbName('RightArrow');
downKey=KbName('LeftArrow');


Screen('TextSize', window, 20);
Screen('TextFont', window, 'helvetica');



cStart=1024/2;

while stop==0

    keyIsDown=1;
    while keyIsDown==1
        [keyIsDown, secs,keyCode] = KbCheck;
    end

    % change gamma table for color c

    newTab=gTab;
    newTab(c,:)=[cStart cStart cStart]/1024;
    newTab(c,:)




    Screen('FillRect', window, c);

    Screen('FillRect', window, c-1, rect);
    Screen('DrawText', window, ['color ', num2str(cStart)  ' ' ], white, 50, 50);
    Screen('Flip', window);


    oldTab=Screen('LoadNormalizedGammaTable', window, newTab);

    rbTab=Screen('ReadNormalizedGammaTable', window);

    if 0 & ~isequal(rbTab, newTab)
        fprintf('niet gelijk\n');
    end


    % wait for keypress
    while 1

        [keyIsDown,secs,keyCode] = KbCheck;

        if keyCode(stopKey)==1
            stop=1;
            break
        end


        if keyCode(upKey)==1
            cStart=cStart+1;

            break
        end
        if keyCode(downKey)==1
            cStart=cStart-1;

            break
        end



    end



end

% restore original gamma table
Screen('LoadNormalizedGammaTable', window, gTab);



Screen('CloseAll');
% catch
%     %this "catch" section executes in case of an error in the "try" section
%     %above.  Importantly, it closes the onscreen window if its open.
%     Screen('CloseAll');
%     commandwindow;
%     rethrow(lasterr);
% end %try..catch.

