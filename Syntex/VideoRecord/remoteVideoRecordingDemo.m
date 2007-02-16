function RemoteVideoRecordingDemo
% RemoteVideoRecordingDemo
%
% Demonstrates remote controllable  video capture and recording to a Quicktime movie
% file. Only works on OS/X and Windows for now. Only works with default
% codec and encoding parameters for now.
% requires file remoteVideo.m for its functionality
% currently filename is supplied with this function. this should change,
% obviously
%
% old comments:
% 'moviename' name of output movie file. The file must not exist at start
% of recording. 'withsound' If set to non-zero, sound will be recorded as
% well (default: record sound). 'showit' If non-zero, video will be shown
% onscreen during recording (default: Show it).
%
% This is early beta code, expect bugs and rough edges!

% History:
% 11.2.2007 Written (MK).
% 13.2.2007 fwc adapted

clear all;
AssertOpenGL;
commandwindow;
disp(['start ' mfilename]);

quitkey=KbName('ESCAPE');
modkey=KbName('LeftGUI');


if ~IsOSX & ~IsWin
    error('Sorry, this demo currently only works on OS/X and Windows.');
end


% initialize settings for remote control
[status, rmv]=remoteVideo('init');
if status~=1
    disp('error initializing');
    return
end

% open connection for remote control

[status, rmv]=remoteVideo('open', rmv);

if status~=1
    disp('error opening connection');
    return
end

rmv.recordingOn=0;
rmv.waitforimage=1;
rmv.displayOn=1;

if nargin < 1
    %     error('You must provide a quicktime output movie name as first argument!');
    moviename='testmovie';
end
moviename

if exist(moviename)
    if ~strcmp(moviename, 'testmovie')
        error('Moviefile must not exist! Delete it or choose a different name.');
    end
end

if nargin < 2 || isempty(withsound)
    withsound = 2;
end

if withsound > 0
    withsound = 2;
end

if nargin < 3
    showit = 1;
end

if showit > 0
    rmv.waitforimage = 1;
else
    rmv.waitforimage = 2;
end

try
    InitializeMatlabOpenGL;

    screen=max(Screen('Screens'));

    win=Screen('OpenWindow', screen, max(Screen('Screens')));

    % Initial flip to a blank screen:
    Screen('Flip',win);

    % Set text size for info text. 24 pixels is also good for Linux.
    Screen('TextSize', win, 24);


    % start remote control loop
    i=0;
    pctime=GetSecs;
    stop=0;
    while stop==0

        i=i+1;
        [keyIsDown, secs, keyCode] = KbCheck();

        if 1==keyCode(quitkey) && 1==keyCode(modkey)
            break;
        end

        % check whether connection is still live
        [status, rmv]=remoteVideo('check', rmv);

        if status~=1
            disp('no connection');
            break;
        end

        % check if a command has been send
        [cstr, rmv]=remoteVideo('receive', rmv);
        if cstr==-1
            fprintf( '.');
            if mod(i,40)==0
                fprintf( '\n');
            end
            if rmv.recordingOn==0
                WaitSecs(0.05);
            end
            cstr='no';
        else
            cstr=cstr(1:end-1);
            ctime=GetSecs; % commandtime
            fprintf( '\ncommand: %s (%d) delta: %.1f  ms\n', cstr, length(cstr), (ctime-pctime)*1000);
            pctime=ctime;
        end


        switch(lower(cstr))
            case 'start',
                % start recording, grab first texture
                % Capture video + audio to disk:
                grabber = Screen('OpenVideoCapture', win, 0, [0 0 640 480],[] ,[], [] , moviename, withsound);
                brightness = Screen('SetVideoCaptureParameter', grabber, 'Brightness',383)

                % Start capture, request 60 fps. Capture hardware will fall back to
                % fastest supported if its not supported (i think).
                Screen('StartVideoCapture', grabber, 60, 1);
                if 1
                    % create first texture
                    [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, rmv.waitforimage)
                else
                    tex = 0;
                end
                oldpts = 0;
                count = 0;
                t=GetSecs;

                rmv.recordingOn=1;
                rmv.displayOn=1;

            case 'stop',
                % stop recording, close capture object and texture
                telapsed = GetSecs - t
                avgfps = count / telapsed

                Screen('StopVideoCapture', grabber);
                Screen('CloseVideoCapture', grabber);
                Screen('Close', tex);
                tex=0;
                rmv.recordingOn=0;

            case 'displayon',       % switch live display on
                rmv.displayOn=1;

            case 'displayoff',      % switch live display off
                rmv.displayOn=0;

            case 'waitforimageon',  % not tested
                rmv.waitforimage=1;

            case 'waitforimageoff', % not tested
                rmv.waitforimage=2;
            case 'no',
                % do nothing
            case 'shutdown', 
                % close connenction for remote control
                [status, rmv]=remoteVideo('close', rmv);
                if status~=1
                    disp('error closing connection');
                end
                stop=1;
                rmv.recordingOn=0;
                break;
            otherwise,
                disp([mfilename ': Unknown command: ' cstr]);
        end

        % capture video if started
        if rmv.recordingOn==1

            % Wait blocking for next image. If waitforimage == 1 then return it
            % as texture, if waitforimage == 2, do not return it (no preview,
            % but faster).
            [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, rmv.waitforimage, tex);
%             fprintf('tex = %i  pts = %f nrdropped = %i\n', tex, pts, nrdropped);

            if tex>0
                % Draw new texture from framegrabber.
                if rmv.displayOn==1
                    Screen('DrawTexture', win, tex, [], [], 0, 0); %Screen('Rect', win));
                end
                if count>0
                    % Compute delta:
                    delta = (pts - oldpts) * 1000;
                    oldpts = pts;
                    Screen('DrawText', win, sprintf('%.4f', delta), 0, 20, 255);
                end;

                % Show it.
                Screen('Flip', win);
                if 0
                    Screen('Close', tex);
                    tex=0;
                end

            end;

            count = count + 1;
        end;

    end

    Screen('CloseAll');
    disp(['end ' mfilename]);
catch
    disp(['Some error in ' mfilename]);

    Screen('CloseAll');
end;
