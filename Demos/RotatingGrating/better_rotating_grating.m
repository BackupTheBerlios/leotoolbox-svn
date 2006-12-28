function better_rotating_grating

if nargin<2
    ifis=2;
end;

if nargin<1
    numFrames=16;
end;

try
    commandwindow;
    Screen('Preference','SkipSyncTests', 1);
    AssertOpenGL;
    screens=Screen('Screens');
    screenNumber=max(screens);
    w=Screen('OpenWindow',screenNumber);
    [widthp, heightp]=Screen('WindowSize', w);
    [width, height]=Screen('DisplaySize', screenNumber);
    pixelratio=widthp/width;
    spatial=2;
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=(white+black)/2;
    if round(gray)==white
        gray=black;
    end
    inc=white-gray;
    s=min(widthp, heightp) /1;
    [x,y]=meshgrid(-s:s-1, -s:s-1);
    angle=0*pi/180; % 30 deg orientation.
    f=0.2/34*2*pi; % cycles/pixel
    a=cos(angle)*f;
    b=sin(angle)*f;
    for i=1:numFrames
        phase=(i/numFrames)*2*pi
        m=sin(a*x+b*y+phase);
        gratingtex=(gray+inc*m);
        tex(i)=Screen('MakeTexture', w, gratingtex);
    end
    i
    tavg=0;
    ifi_duration = Screen('GetFlipInterval', w)
    movieDurationSecs=2.5;
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)
        frameRate=60; % 60 Hz is a good guess for flat-panels...
    end
    movieDurationFrames=round(movieDurationSecs * frameRate / ifis)
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel)
    Screen('FillRect',w, gray);
    vbl = Screen('Flip', w);
    tic
    rotSp=60; %( deg/s)
    movieFrameAngle=(0:(length(movieFrameIndices)-1))*(rotSp/frameRate);
    lengthMovieFrameAngle=length(movieFrameAngle)
    lengthMovieFrameIndices=length(movieFrameIndices)

    if length(movieFrameAngle)~=length(movieFrameIndices)
        error('Error: Different length of movie index and angle vectors');
    end
    i=0; j=0;
    Screen('Flip', w);
    t1=Getsecs;
    tx=GetSecs;
    if 1 % do not use movieFrameAngle vector, but calculate angle based on time passed
        while 1
            i=i+1;
            if i>length(tex)
                i=1;
            end
            tx=GetSecs;
            angle=rotSp*(GetSecs-t1);
            Screen('DrawTexture', w, tex(movieFrameIndices(i)), [], [], angle);
            vbl=Screen('Flip', w);

            tavg=tavg+(GetSecs - tx);
            j=j+1;
            tx=GetSecs;

            % We also abort on keypress...
            if KbCheck
                break;
            end;
        end
    else
        while 1
            for i=1:length(movieFrameIndices)
                Screen('DrawTexture', w, tex(movieFrameIndices(i)), [], [], movieFrameAngle(i));
                vbl=Screen('Flip', w);

                tavg=tavg+(GetSecs - tx);
                j=j+1;
                tx=GetSecs;

                % We also abort on keypress...
                if KbCheck
                    break;
                end;
            end
            if KbCheck
                break;
            end;
        end
    end
    toc
    Priority(0);

    tavg=tavg / j  % average frameduration

    % We're done: Close all windows and textures:
    Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try"    section
    %above. Importantly, it closes the onscreen window if its open.
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end %try..catch..
