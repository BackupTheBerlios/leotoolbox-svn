function [rating, rt, stop]=mult_SliderResponse(window, judg_cellstrs, instr)

quitKey=KbName('ESCAPE');
stopKey = KbName('SPACE');
nJudg = size(judg_cellstrs,2);
gray=round(GrayIndex(window));
rating = ones(1,nJudg)*-0; % unlikely value
col=[0 0 255];
rect=[0 0 25 25];
for ind = 1 : nJudg
    oldRects{ind}=[0 0 1 1];
    dRects{ind} = [0 0 1 1];
end

Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1);


[h,v]=WindowSize(window);
sv=round(0.9*v);

[a,b]=WindowCenter(window);
ShowCursor;

WaitSetMouse(a,b,window);
omx=-1;
omy=-1;
stop=0;
r=-7777;
rt=-88888;
i=1;
insetSlider=20;
lineSlider=2;

minSlider=round(insetSlider/100*h);
maxSlider=round((100-insetSlider)/100*h);
lineSlider=round(lineSlider/100*v);
colSlider=[0 255 0];
for ind = 1:nJudg
    svs(ind)=0.9*v/nJudg*ind;
    dRects{ind} = CenterRectOnPoint(rect, a, svs(ind));
end


t1=GetSecs;
mousedown = 0;
nearest_slider = -1;
origin=a; % -50 - +50
% origin=minSlider; % 0-100
first=1;
while 1
    WaitSecs(.002);
                
    status=VideoRecorder('gettimestampnoblock');
%     status=VideoRecorder('gettimestamp');

    % get mouse buttons:
    % make sure the experiment screen contains the menu bar at the
    % top!!!
    [mx, my, buttons]=GetMouse(window);

    % if mouse moved
    if omx~=mx || omy~=my
        % rescale
        mxs=round(origin+((mx-origin)*(100-2*insetSlider)/100));

        % check for each slider
        for ind=1:nJudg

            if nearest_slider ==ind || first==1
                dRects{ind} = CenterRectOnPoint(rect, mxs, svs(ind));
                Screen('FillOval', window, gray, oldRects{ind} );

                Screen('DrawLine', window ,colSlider, minSlider, svs(ind), maxSlider, svs(ind) ,3);
                Screen('DrawLine', window ,colSlider, a, svs(ind)-lineSlider, a, svs(ind)+lineSlider ,3);
                Screen('DrawLine', window ,colSlider, minSlider, svs(ind)-lineSlider, minSlider, svs(ind)+lineSlider ,3);
                Screen('DrawLine', window ,colSlider, maxSlider, svs(ind)-lineSlider, maxSlider, svs(ind)+lineSlider ,3);
                if first==1
                    Screen('DrawText', window, judg_cellstrs{ind}, maxSlider+20,svs(ind));
                    Screen('DrawText', window, instr,20,0.05*v);
                end
                Screen('FillOval', window, [255 0 0], dRects{ind} );
                oldRects{ind}=dRects{ind};
            end
        end

        Screen('Flip', window, [], 1);
        first=0;
    end

    % find nearest slider on mouse press
    if any(buttons)
        mousedown = 1;
        rt=GetSecs-t1;
        r=(mxs-origin)/(maxSlider-minSlider)*100;
        nearest_slider = getNearest(my,svs);
    else
        if mousedown==1 % fix rating on release
            mousedown = false;
            rating(nearest_slider) = r;
            nearest_slider = 0;
        end
        omx=mx;
        omy=my;
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(stopKey)==1
            break;
        elseif keyCode(quitKey)==1 % stop experiment
            rt=-9999;
            stop=1;
            break;
        end

        i=i+1;
    end
end

HideCursor;
%waitForMouseButtonRelease;
waitForRelease;
