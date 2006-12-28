% this silly demo will show a number of textures on screen arranged on a cirlce
% it will also react to mouse press by drawing a little coloured dot

try
    commandwindow; % moves commandwindow up front, handy in case of a break.
    fprintf('%s (%s)\n click on ESC key to stop\n', mfilename, datestr(now));

    stimdir='stimuli';
    if 7~=exist(stimdir, 'dir')
        fprintf('Directory ''%s'' does not exist\n', stimdir);
        return;
    end

    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.

    screenNumber=max(Screen('Screens'));

    % Open a double buffered fullscreen window and draw a gray background
    % and front and back buffers.
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);

    % Find the color values which correspond to white and black and gray
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen

    drect=CenterRect([0 0 RectHeight(wRect)/2 RectHeight(wRect)/2], wRect);
    quitkey=KbName('Escape');
    stimlist=dir('stimuli');
    i=1;
    einde=0;
    while einde==0
        ptlist=[];
        npts=0;
        mystimfile=fullfile(stimdir,stimlist(i).name)
        %         exist(mystimfile, 'file')
        if 2==exist(mystimfile, 'file') & stimlist(i).name(1)~='.'

            Screen('FillRect',w, gray);

            ima=imread(mystimfile, 'jpg');
            stimtex=Screen('MakeTexture', w, ima);
            Screen('DrawTexture', w, stimtex, [], drect);
            Screen('Flip',w);
            tStart=GetSecs;
            while KbCheck; end
            tEnd=GetSecs+5;
            while 1
                [keyIsDown,secs,keyCode] = KbCheck;
                [mx, my, buttons]=GetMouse(w);

                if keyCode(quitkey)
                    %                     fprintf('quit\n');
                    einde=1;
                    break;
                end
                if keyIsDown
                    %                     fprintf('keydown\n');
                    break;
                end
                if GetSecs>tEnd
                    %                     fprintf('time\n');
                    break;
                end

                if any(buttons)
                    %                     fprintf('button\n');
                    npts=npts+1;
                    ptlist(npts,:)=[mx my GetSecs-tStart rand(1,3)*255];
                    Screen('DrawTexture', w, stimtex, [], drect);
                    for p=1:npts
                        myrect=CenterRectOnPoint([0 0 11 11], ptlist(p,1), ptlist(p,2));
                        Screen('FillOval', w, ptlist(p,4:6), myrect);
                    end
                    Screen('Flip',w);
                    while any(buttons)
                        [mx, my, buttons]=GetMouse(w);
                    end
                end

            end % wait max for 5 secs for a key press

        end
        ptlist;
        i=i+1;
        if i>length(stimlist)
            einde=1;
        end
    end


    %The same commands which closes onscreen and offscreen windows also
    %closes textures.
    Screen('CloseAll');
    ShowCursor;
    fprintf('End of %s\n\n', mfilename);

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    ShowCursor;
    rethrow(lasterror);
    commandwindow; % moves commandwindow up front, handy in case of a break.
end %try..catch..


