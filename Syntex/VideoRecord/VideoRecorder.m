function [status tex ts]=VideoRecorder( commandstr, varargin)
% shell around the Screen video capture abilities
%
% USAGE: status=videoRecorder(command, varargin)
%
% Demonstrates video capture and recording to a Quicktime movie
% file. Only works on OS/X and Windows for now. Only works with default
% codec and encoding parameters for now.
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
% 09.5.2007 fwc adapted to simpler  video recorder shell script

persistent vr; % structure to hold video recorder settings

status=0;
tex=[];
ts=[];

if ~exist('commandstr', 'var') || isempty(commandstr)
    error([mfilename ' USAGE: status=videoRecorder(commandstr, varargin)']);
end

% disp([mfilename ': ' lower(commandstr)]);
ctime=GetSecs; % commandtime

if ~IsOSX && ~IsWin
    error('Sorry, this currently only works on OS/X and Windows.');
end


switch(lower(commandstr))
    case {'init', 'initdummy'},

        if strcmpi(commandstr, 'initdummy')
            disp(['Opening ' mfilename ' in dummy mode.']);
            vr.dummymode=1;
        else
            vr.dummymode=0;
        end
        % set some defaults
        if 1
            vr.imwidth=640;
            vr.imheigth=480;
        else
            vr.imwidth=320;
            vr.imheigth=240;
        end
        vr.captureArea=[0 0  vr.imwidth vr.imheigth];

        vr.recordingOn=0;
        vr.displayOn=0; % If non-zero, video will be shown onscreen during recording (default: Show it).
        vr.logFramesOn=0;
        vr.withsound = 2; % 'withsound' If set to non-zero, sound will be recorded as well (default: record sound).
        vr.ts=-1;
        vr.oldts=-1;
        vr.tex=0;
        vr.count=-1;
        vr.totcnt=-1;
        vr.telapsed=-1;
        vr.avgfps=-1;
        vr.delta=-1;
        vr.logfp=-1;

        vr.quitkey=KbName('ESCAPE');
        vr.modkey=KbName('LeftGUI');

        if ~isfield(vr, 'moviedir') || isempty(vr.moviedir)
            vr.moviedir='movierec';
        end
        if ~isfield(vr, 'moviename') || isempty(vr.moviename)
            vr.moviename='testmovie';
        end
        if ~isfield(vr, 'extension') || isempty(vr.extension)
            vr.extension='.mov';
        end

        vr.movieStartTime=0;
        vr.waitTime=0.001;
        vr.grabber=-1;
        % specify the video codec
        % the codec is added to the moviefilename
        vr.codec=0;

        switch(vr.codec)
            case 0,
                vr.codec = ''; % uncompresed
            case 1,
                vr.codec = ':CodecType=1635148593'; % H.264 codec.
            case 2,
                vr.codec = ':CodecType=1886940276'; % Apple Pixlet Video codec.
            case 3,
                vr.codec = ':CodecType=1836070006'; % MPEG-4 Video codec.
            case 4,
                vr.codec = ':CodecType=2037741106'; % Component Video codec.
            case 5,
                vr.codec = ':CodecType=1685480304'; % DV - PAL codec.
            case 6,
                vr.codec = ':CodecType=1685480224'; % DVCPRO - NTSC codec.
            case 7,
                vr.codec = ':CodecType=1685483632'; % DVCPRO - PAL codec.
            case 8,
                vr.codec = ':CodecType=1685468526'; % DVCPRO50 - NTSC codec.
            case 9,
                vr.codec = ':CodecType=1685468528'; % DVCPRO50 - PAL codec.
            otherwise
                vr.codec = '';
                disp([mfilename ': error: Unknown codec specified, recording uncompressed.']);
        end

        if nargin>=1
            vr.win=varargin{1};
        else
            vr.win=max(Screen('Screens'));
        end

        % Capture video + audio to disk:
        if vr.dummymode==0
            %             vr.grabber = Screen('OpenVideoCapture', vr.win, 0, [0 0 vr.imwidth vr.imheigth],[] ,[], [] ,[vr.moviefullname vr.codec vr.extension], vr.withsound);
            vr.grabber = Screen('OpenVideoCapture', vr.win, 0, vr.captureArea,[] ,[], [] ,[vr.moviefullname vr.codec vr.extension], vr.withsound);
            %             vr.grabber = Screen('OpenVideoCapture', vr.win, [], [0 0 vr.imwidth vr.imheigth],[] ,[], [] ,[vr.moviefullname vr.codec vr.extension], vr.withsound);
            if vr.grabber<0
                disp([mfilename ': No grabber available.']);
                vr.dummymode=1;
            end
        end
        % create a fake movie file in case we're in dummy mode
        if vr.dummymode==1
            fp=fopen([vr.moviefullname vr.extension], 'w');
            fprintf(fp, 'Running in dummy mode');
            fclose(fp);
            vr.grabber=-1;
        end

        % close any open logfile
        if isfield(vr, 'logfp') && vr.logfp>0
            fclose(vr.logfp);
            vr.logfp=0;
        end
        % open new logfile
        vr.logfilename=[vr.moviefullname '_log' '.txt'];
        vr.logfp=fopen(vr.logfilename,'a');
        if vr.logfp<0
            error([mfilename ': error, unable to open movie log file: ' vr.logfilename] );
        end
        % print movie name
        disp([mfilename ': Movie name: ' vr.moviefullname vr.extension]);
        disp([mfilename ': Logfilename: ' vr.logfilename]);
        fprintf(vr.logfp, 'Movie name: %s\n', vr.moviefullname);
        fprintf(vr.logfp, 'Logfilename: %s\n', vr.logfilename);

        if vr.dummymode==1
            fprintf(vr.logfp, [ mfilename ': initialized in dummymode.\n']);
            disp([ mfilename ': initialized in dummymode.\n']);
        else
            fprintf(vr.logfp, [ mfilename ': initialized.\n']);
            disp([ mfilename ': initialized.\n']);
        end



    case 'indummymode',

        status=vr.dummymode;
        return;
    case 'message',

        % we record message at the most recent timestamp obtained
        % we could also get a new one here, but this may cause delays (up
        % to 50 ms, at 20 Hz recording speed
        VideoRecorder('gettimestampnoblock'); % this should update vr.ts if a new frame has become available
        %         ts
        mtime=ctime-vr.movieStartTime; % message time
        if isfield(vr, 'logfp') && vr.logfp>0
            fprintf(vr.logfp, '%f MES %f %s\n', vr.ts, mtime, varargin{1});
        else
            disp( [mfilename ':error printing message: log file not open.']);
        end
    case 'moviename',
        vr.moviename=varargin{1};
        vr.extension='.mov';
        vr.moviefullname=[vr.moviedir filesep vr.moviename];
        i=0;

        temp=vr.moviefullname;
        while 2==exist([temp  vr.extension]) % if file already exists, add a nuumber until file does not exist
            i=i+1;
            temp=[vr.moviefullname num2str(i)];
        end
        vr.moviefullname=temp;
        %         disp([mfilename ': Movie name: ' vr.moviefullname vr.extension]);
        %         DrawFormattedText(vr.win, ['Movie: ' moviefullname],[],80, white);

    case 'moviedir',
        vr.moviedir=varargin{1};
        makedir(vr.moviedir);
        %         disp([mfilename ': Movie dir: ' vr.moviedir]);

        %         DrawFormattedText(vr.win, ['Moviedir: ' vr.moviedir],[],160, white);

    case {'start', 'startrecording'},
        % start recording, and grab first texture
        %         % Capture video + audio to disk:
        %         if vr.dummymode==0
        %             vr.grabber = Screen('OpenVideoCapture', vr.win, 0, [0 0 vr.imwidth vr.imheigth],[] ,[], [] ,[vr.moviefullname vr.codec vr.extension], vr.withsound);
        %             if vr.grabber<0
        %                 disp([mfilename ': No grabber available, running in dummymode!']);
        %                 vr.dummymode=1;
        %             end
        %         else
        %             vr.grabber=-1;
        %         end

        % Start capture, request 60 fps. Capture hardware will fall back to
        % fastest supported if its not supported (i think).

        if vr.dummymode==0
            Screen('StartVideoCapture', vr.grabber, 60, 1);
        end

        vr.ts=GetSecs; % start time
        if 1 && vr.dummymode==0
            % grab first texture
            [vr.tex vr.ts vr.nrdropped]=Screen('GetCapturedImage', vr.win, vr.grabber, 1); % waitforimage =1, so we can be sure images get captured
        elseif vr.dummymode==1
            vr.ts=GetSecs;
            vr.nrdropped=0;
            % should we make a texture?
            %             disp('first dummy texture');
            imdata=round(rand(vr.imheigth, vr.imwidth)*255);
            if vr.tex >0 % close existing texture
                Screen('Close', vr.tex);
            end
            vr.tex=Screen('MakeTexture', vr.win, imdata);
        else
            vr.tex = 0;
        end

        if vr.tex>0
            vr.movieStartTime=GetSecs;
            vr.recordingOn=1;
            vr.count = 1;
            vr.totcnt=vr.nrdropped;
            fprintf(vr.logfp, '%f MES start recording.\n', vr.ts );
            if 1==vr.logFramesOn
                fprintf(vr.logfp, '%f FRM %d totcnt %d delta %f nrdropped %d\n', vr.ts, vr.count, vr.totcnt, 0, vr.nrdropped);
            end
        else
            error([mfilename ': error: no valid texture obtained.']);
        end
        ts=vr.ts;
        tex=vr.tex;
    case {'stop', 'stoprecording'},
        % stop recording, close capture object and texture
        if vr.dummymode==0
            Screen('StopVideoCapture', vr.grabber);
        end
        vr.telapsed = GetSecs - vr.ts;
        vr.avgfps = vr.count / vr.telapsed;
        fprintf(vr.logfp,'%f MES stop recording\n', vr.ts );
        fprintf(vr.logfp,'%f MES movie duration: %f\n', vr.ts, GetSecs-vr.movieStartTime );
        fprintf(vr.logfp,'%f MES avgfps: %f\n', vr.ts, vr.avgfps );
        if vr.dummymode==0
            Screen('CloseVideoCapture', vr.grabber );
            vr.grabber=-1;
        end
        if vr.tex>0
            Screen('Close', vr.tex);
        end
        vr.tex=0;
        vr.recordingOn=0;
        % close logfile
        if vr.logfp>0
            fclose(vr.logfp);
            vr.logfp=0;
        end
    case 'displayon',       % switch live display on
        vr.displayOn=1;
    case 'displayoff',      % switch live display off
        vr.displayOn=0;
    case 'logframeson',       % switch frame logging on
        vr.logFramesOn=1;
    case 'logframesoff',       % switch frame logging off
        vr.logFramesOn=0;
    case 'soundon',       % switch sound recording on
        vr.withsound=2;
    case 'soundoff',       % switch sound recording off
        vr.withsound=0;
    case {'getframe', 'gettimestamp', 'gettimestampnoblock'}, % get image (and) timestamp
        if strcmpi( commandstr, 'gettimestamp')
            waitforimage=2;
        elseif strcmpi( commandstr, 'getframe')
            waitforimage=1;
        elseif strcmpi( commandstr, 'gettimestampnoblock')
            waitforimage=0;
        else
            waitforimage=1;
        end
        % capture video if started, get texture with image
        if vr.recordingOn==1

            % Wait blocking for next image. If waitforimage == 1 then return it
            % as texture, if waitforimage == 2, do not return it (no preview,
            % but faster). Recycle texture.
            if vr.dummymode==0
                [vr.tex vr.ts vr.nrdropped]=Screen('GetCapturedImage', vr.win, vr.grabber, waitforimage, vr.tex);
            elseif waitforimage==1
                % should we make a texture?
                %                 disp('dummy texture');

                imdata=round(rand(vr.imheigth, vr.imwidth)*255);
                if vr.tex >0 % close existing texture
                    Screen('Close', vr.tex);
                end
                vr.tex=Screen('MakeTexture', vr.win, imdata);
                vr.ts=GetSecs;
                vr.nrdropped=0;
            elseif waitforimage==2
                vr.ts=GetSecs;
                vr.nrdropped=0;
                if vr.tex >0 % close existing texture
                    Screen('Close', vr.tex);
                end
                vr.tex=0; % do not return a valid texture.
            end

            if vr.tex>0
                % Draw new texture from frame grabber.
                if vr.displayOn==1 % live display
                    Screen('DrawTexture', vr.win, vr.tex, [], [], 0, 0);
                end
                if vr.count>0
                    % Compute frame interval delta:
                    vr.delta = (vr.ts - vr.oldts) * 1000;
                    vr.oldts = vr.ts;
                    vr.totcnt=vr.totcnt+vr.nrdropped;
                    %                     disp([mfilename ': ' commandstr ': frame interval: ' num2str(vr.delta)]);
                    %                     Screen('DrawText', vr.win, sprintf('%.4f', vr.delta), 0, 20, vr.textColour);
                    if 1==vr.logFramesOn
                        fprintf(vr.logfp, '%f FRM %d totcnt %d frame interval %f nrdropped %d\n', vr.ts, vr.count, vr.totcnt, vr.delta, vr.nrdropped);
                    end
                end

                % Show it.
                if 0 & vr.displayOn==1 % live display
                    Screen('Flip', vr.win);
                end
                if 0
                    Screen('Close', vr.tex);
                    vr.tex=0;
                end
                vr.count = vr.count + 1;
            end
            ts=vr.ts;
            tex=vr.tex;
        end
    case 'no',
        % do nothing
    otherwise,
        disp([mfilename ': Unknown command: ''' commandstr '''' ]);
end

status=1;