function remoteVideoRecorder
% RemoteVideoRecorder
%
% Demonstrates remote controllable  video capture and recording to a Quicktime movie
% file. Only works on OS/X and Windows for now. Only works with default
% codec and encoding parameters for now.
% requires file remoteVideo.m for its functionality
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
% 13.4.2007 fwc further adapted

clear all;
AssertOpenGL;
commandwindow;
home;
cd(FunctionFolder(mfilename));
disp(['start ' mfilename]);

quitkey=KbName('ESCAPE');
modkey=KbName('LeftGUI');

moviedir='movies';
movieStartTime=-1;
waitTime=0.001;

if ~IsOSX && ~IsWin
    error('Sorry, this demo currently only works on OS/X and Windows.');
end


% initialize settings for remote control
[status, rmv]=remoteVideo('init');
if status~=1
    disp('error initializing');
    return
end

rmv.logFramesOn=0;

% open connection for remote control

[status, rmv]=remoteVideo('open', rmv);

if status~=1
    disp('error opening connection');
    return
end

rmv.recordingOn=0;
rmv.waitforimage=1;
rmv.displayOn=1;
rmv.logFramesOn=1;

if nargin < 1
    %     error('You must provide a quicktime output movie name as first argument!');
    moviename='testmovie';
end

if exist(moviename)
    if ~strcmp(moviename, 'testmovie')
        disp('Moviefile must not exist! Delete it or choose a different name.');
        error('Stopping');
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

% specify the video codec
% the codec is added to the moviefilename
codec=0;

if isempty(codec)
    codec = '';
else
    switch(codec)
        case 0,
            codec = '';
        case 1,
            codec = ':CodecType=1635148593'; % H.264 codec.
        case 2,
            codec = ':CodecType=1886940276'; % Apple Pixlet Video codec.
        case 3,
            codec = ':CodecType=1836070006'; % MPEG-4 Video codec.
        case 4,
            codec = ':CodecType=2037741106'; % Component Video codec.  
        case 5,
            codec = ':CodecType=1685480304'; % DV - PAL codec.
        case 6,
            codec = ':CodecType=1685480224'; % DVCPRO - NTSC codec.
        case 7,
            codec = ':CodecType=1685483632'; % DVCPRO - PAL codec.
        case 8,
            codec = ':CodecType=1685468526'; % DVCPRO50 - NTSC codec.
        case 9,
            codec = ':CodecType=1685468528'; % DVCPRO50 - PAL codec.
        otherwise
            error('Unknown codec specified, only know types 0 to 9.');
    end
end


% try

    screen=max(Screen('Screens'));

    win=Screen('OpenWindow', screen, max(Screen('Screens')));

    % Set text size for info text. 24 pixels is also good for Linux.
    Screen('TextSize', win, 48);

    white=WhiteIndex(win);
    gray=GrayIndex(win);
    Screen('FillRect', win, gray);
    DrawFormattedText(win, 'Remote Video Recorder: ready',[],[], white);
    % Initial flip to a blank screen:

    Screen('Flip',win);
    % start remote control loop
    i=0;
    np=MaxPriority(win);
    op=Priority(np);
    pctime=GetSecs;
    stop=0;
    while stop==0

        i=i+1;
        [keyIsDown, secs, keyCode] = KbCheck();

        if 1==keyCode(quitkey) && 1==keyCode(modkey)
            stop=1;
            break;
        end

        % check whether connection is still live
        [status, rmv]=remoteVideo('check', rmv);

        if status~=1
            disp('no connection');
            stop=1;
            break;
        end

        % check if a command has been send
        [cstr, rmv]=remoteVideo('receive', rmv);
        if cstr==-1
            %             fprintf( '.');
            %             if mod(i,100)==0
            %                 fprintf( '\n');
            %             end
            if rmv.recordingOn==0
                WaitSecs(waitTime);
            end
            cstr='no';

        else % possibly a command received
            cstr=cstr(1:end-1);
            ctime=GetSecs; % commandtime
            %             fprintf( '\ncommand: %s (%d) delta: %.1f  ms\n', cstr, length(cstr), (ctime-pctime)*1000);
            pctime=ctime;

            if strncmpi(cstr, 'message', length('message'))
                message=cstr((length('message')+1):end);
                while strncmp(message, ' ',1)==1 % remove spaces
                    message=message(2:end);
                end
                if movieStartTime>0
                    mtime=ctime-movieStartTime;
                else
                    mtime=GetSecs;
                end
                fprintf('%.3f MES %s\n', mtime, message);
            elseif strncmpi(cstr, 'moviename', length('moviename'))
                moviename=cstr((length('moviename')+1):end);
                while strncmp(moviename, ' ',1)==1 % remove spaces
                    moviename=moviename(2:end);
                end
                moviefullname=[moviedir filesep moviename];

                if exist(moviefullname, 'file')
                    if ~strcmp(moviename, 'testmovie')
                        disp(['Warning: ' moviefullname ' does exist! Delete it or choose a different name.']);
                        error('Stopping now');
                    end
                end

                diary off;
                diary([moviefullname '_log' '.txt']);
                DrawFormattedText(win, ['Movie: ' moviefullname],[],80, white);
                Screen('Flip',win);

            elseif strncmpi(cstr, 'moviedir', length('moviedir'))
                moviedir=cstr((length('moviedir')+1):end);
                while strncmp(moviedir, ' ',1)==1 % remove spaces
                    moviedir=moviedir(2:end);
                end
                makedir(moviedir);
                DrawFormattedText(win, ['Moviedir: ' moviedir],[],160, white);
                Screen('Flip',win);
            else

                switch(lower(cstr))
                    case 'start',
                        % start recording, grab first texture
                        % Capture video + audio to disk:
%                         grabber = Screen('OpenVideoCapture', win, 0, [0 0 320 240],[] ,[], [] ,[moviefullname codec], withsound);
                        grabber = Screen('OpenVideoCapture', win, 0, [0 0 640 480],[] ,[], [] ,[moviefullname codec], withsound);
%                         grabber = Screen('OpenVideoCapture', win, 0, [0 0 640 480],[] ,[], [] , moviefullname, withsound);
%                         Screen('SetVideoCaptureParameter', grabber, 'printParameters'); % prints info to screen
%                         brightness = Screen('SetVideoCaptureParameter', grabber, 'Brightness',383)

                        % Start capture, request 60 fps. Capture hardware will fall back to
                        % fastest supported if its not supported (i think).
                        Screen('StartVideoCapture', grabber, 60, 1);
                        if 1
                            % create first texture
                            [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, rmv.waitforimage);
                        else
                            tex = 0;
                        end
                        oldpts = 0;
                        count = 0;
                        totcnt=nrdropped;
                        t=GetSecs;

                        rmv.recordingOn=1;
                        rmv.displayOn=1;
                        if tex>0
                            movieStartTime=GetSecs;
                            fprintf('%f MES start recording\n', pts );
                            if 0 && 1==rmv.logFramesOn
%                               fprintf('%f FRM %d delta %f nrdropped %d\n', pts, count, 0, nrdropped);
                                fprintf('%f FRM %d totcnt %d delta %f nrdropped %d\n', pts, count, totcnt, 0, nrdropped);
                            end
                        end

                    case 'stop',
                        % stop recording, close capture object and texture
                        telapsed = GetSecs - t;
                        avgfps = count / telapsed;
                        fprintf('%f MES stop recording, avgfps: %f\n', pts, avgfps );
                        Screen('StopVideoCapture', grabber);
                        Screen('CloseVideoCapture', grabber);
                        Screen('Close', tex);
                        tex=0;
                        rmv.recordingOn=0;

                    case 'displayon',       % switch live display on
                        rmv.displayOn=1;

                    case 'displayoff',      % switch live display off
                        rmv.displayOn=0;
                    case 'logframeson',       % switch frame logging on
                        rmv.logFramesOn=1;
                    case 'logframesoff',       % switch frame logging off
                        rmv.logFramesOn=0;

                    case 'waitforimageon',  % not tested
                        rmv.waitforimage=1;

                    case 'waitforimageoff', % not tested
                        rmv.waitforimage=2;
                    case 'no',
                        % do nothing
                    case 'shutdown',
                        % close connention for remote control
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
            end
        end % if command received

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
                    totcnt=totcnt+nrdropped;
                    Screen('DrawText', win, sprintf('%.4f', delta), 0, 20, 255);
                    if 00 && 1==rmv.logFramesOn
                        fprintf('%f FRM %d totcnt %d delta %f nrdropped %d\n', pts, count, totcnt, delta, nrdropped);
                    end
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

        WaitSecs(waitTime);
        
    end
    diary off;
    Priority(op);
    Screen('CloseAll');
    disp(['end ' mfilename]);
% catch
%     disp(['Some error in ' mfilename]);
%     Priority(0);
%     Screen('CloseAll');
% end;
