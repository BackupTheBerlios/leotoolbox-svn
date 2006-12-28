% simple PTB OS X demo
% the more useful bits are based on an example provided by Allen Ingling
% that came with PTB OSX 0.1
% this demo has been tested with matlab 7.2 and PTB version 3 running under
% Mac OS 10.4.5

try
    clear all;
    commandwindow;
    fprintf('%s\n\n\t', mfilename);
    fprintf('At the end of the demo, press any key to quit\n\n\t');

    nobjects=500; % nr of objects to draw
    steps=5;

    %Get display info
    displays= Screen('Screens');
    displayScreen=max(displays);
    [w, wRect]=Screen('OpenWindow',displayScreen, [],[],32,2);
    white=WhiteIndex(w);
    black=BlackIndex(w);
    gray=GrayIndex(w);

    %display some stuff
    Screen('FillRect', w, gray);
    Screen('Flip', w);
    wHeight=RectHeight(wRect);
    wWidth=RectWidth(wRect);

    [x0,y0] = RectCenter(wRect);
    side=round(wHeight/10);
    r=round(wHeight/2);
    step=360/steps;

    n=0;
    
    while n<nobjects;
        for a=0:step:359.9
            n=n+1;
            x = x0 + rand * r * sin(a/360*2*pi); % x
            y = y0 + rand * r * cos(a/360*2*pi); % y
            rect=CenterRect([0 0 side side], wRect);
            newRect = CenterRectOnPoint(rect, x, y);
            dac=rand(3,1)*255; % let's assume we've 8-bit dacs
            if rand>0.5
                Screen('FillOval', w, dac, newRect);
            else
                Screen('FillRect', w, dac, newRect);
            end
            Screen('Flip', w,[],1);

        end

    end
    Screen('Flip', w);

    while KbCheck, end
    tEnd=GetSecs+5;
    while ~KbCheck & GetSecs < tEnd, end


    Screen('CloseAll');
    fprintf('End of %s\n', mfilename);
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..
