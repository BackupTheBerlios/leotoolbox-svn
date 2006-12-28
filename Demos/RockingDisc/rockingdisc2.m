clear all;
fprintf('Simple OSX Demo\n\n\t');
fprintf('At the end of the demo, press any key to quit\n\n\t');

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
t=v/2;

sz=15; % surround size

r=[0 0 t t];
r=CenterRectInWindow(r,w);
target=InsetRect(r,sz, sz);

s=[0 0 t/2 t/2];
s=CenterRectInWindow(s,w);
offset=t/4;
% k=1;
% for i=-1:2:1
%     for j=-1:2:1
%         s(k,:)=OffsetRect(s,i*offset,j*offset);
%         k=k+1;
%     end
% end
% 

ls=OffsetRect(s, -offset,-offset);
rs=OffsetRect(s, offset,offset);

surroundkey=KbName('s');
stopkey=KbName('ESCAPE');

period=1/1;
contrast=.5;
scon=.5;

background=gray;
Screen('FillRect',w, background);
Screen('Flip', w);

while KbCheck; end
surroundtoggletime=-1;
surroundtoggle=1;
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
%         sc(1)=gray+scon*inc;
%         sc(2)=gray+scon/2*inc;
%         sc(3)=gray-scon*inc;
%         sc(4)=gray-scon/2*inc;
% 
    else
        lsc=background;
        rsc=background;
    end
    
    targetcolour=gray+contrast*inc*cos((GetSecs-ts)/period*2*pi);
%     for i=1:size(s,1)
%         Screen('FillRect',w, sc(i), s(i,:));
%     end
    Screen('FillRect',w, lsc, ls);
    Screen('FillRect',w, rsc, rs);
    Screen('FillOval',w, targetcolour, target);
    
 %   Screen('FillOval',w, targetcolour, rt);
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
