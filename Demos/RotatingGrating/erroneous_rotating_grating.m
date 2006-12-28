function rotating_grating

if nargin<2
    ifis=2;
end;

if nargin<1
    numFrames=1;
end;

try
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
        phase=(i/numFrames)*2*pi;
        m=sin(a*x+b*y+phase);
        gratingtex=(gray+inc*m);
        tex(i)=Screen('MakeTexture', w, gratingtex);
    end

    tavg=0;
    ifi_duration = Screen('GetFlipInterval', w)
    movieDurationSecs=0.5;
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)
        frameRate=60; % 60 Hz is a good guess for flat-panels...
    end
    movieDurationFrames=round(movieDurationSecs * frameRate / ifis);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel)
    Screen('FillRect',w, gray);
    vbl = Screen('Flip', w);
    tic
    for j=0:1:30
        for i=1:movieDurationFrames
            t1=GetSecs;
            Screen('DrawTexture', w, tex(movieFrameIndices(i)), [], [], j);
            vbl=Screen('Flip', w, vbl + (ifis - 0.5) * ifi_duration);

            t1=GetSecs - t1;
            if (i>numFrames)
                tavg=tavg+t1;
            end;

            % We also abort on keypress...
            if KbCheck
                break;
            end;
        end;
    end
    toc
    Priority(0);

    tavg=tavg / (movieDurationFrames - numFrames)

    % We're done: Close all windows and textures:
    Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try"
    section
    %above. Importantly, it closes the onscreen window if its open.
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end %try..catch..
