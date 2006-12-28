clear all;
commandwindow;
fprintf('\n\n\nRocking disc OSX Demo, press s for surround\n\n\t');
fprintf('At the end of the demo, press escape key to quit\n\n\t');

input('Hit the return key to continue.','s');
fprintf('Thanks.\n');

screens=Screen('Screens');
screenNumber=max(screens);

white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=(white+black)/2;
if round(gray)==white
	gray=black;
end
inc=white-gray;



% Open a double buffered fullscreen window and draw a gray background
% and front and back buffers.  On OS X we
w=Screen('OpenWindow',screenNumber, 0,[],32,2);
rect=Screen('Rect',w);
[h,v]=WindowSize(w);
t=v/6;

sz=10; % surround size

r=[0 0 t t];
r=CenterRectInWindow(r,w);
target=InsetRect(r,sz, sz);

%target=CenterRectInWindow(target,w);

offset=h/8;
lt=OffsetRect(target,-offset,0);
rt=OffsetRect(target, offset,0);

ls=OffsetRect(r,-offset,0);
rs=OffsetRect(r, offset,0);

surroundkey=KbName('s');
stopkey=KbName('ESCAPE');

period=1/2;
contrast=.25;
scon=.25;

background=gray;
Screen('FillRect',w, background);
Screen('Flip', w);

while KbCheck; end
surroundtoggletime=-1;
surroundtoggle=0;
f=1;
ts=GetSecs;
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if 1==keyCode(stopkey)
        break;
    end

    if 1==keyCode(surroundkey) & GetSecs-surroundtoggletime>2
        surroundtoggle=1-abs(surroundtoggle);
        surroundtoggletime=GetSecs;
    end

    if surroundtoggle==1
        lsc=gray-scon*inc;
        rsc=gray+scon*inc;
    else
        lsc=background;
        rsc=background;
    end
    
    targetcolour=gray+contrast*inc*cos((GetSecs-ts)/period*2*pi);
    
    Screen('FillRect',w, lsc, ls);
    Screen('FillOval',w, targetcolour, lt);
    
    Screen('FillRect',w, rsc, rs);
    Screen('FillOval',w, targetcolour, rt);
    Screen('Flip', w);

    t(f)=GetSecs-ts;
    c(f)=targetcolour;
    f=f+1;
    
end;
Screen('CloseAll');


dt=diff(t);

fprintf('Median frametime: %f\n', median(dt));
fprintf('Mean frametime: %f\n', mean(dt));
% figure;
% plot(t,c);
fprintf('End of test');
