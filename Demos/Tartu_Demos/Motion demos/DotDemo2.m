
% dot motion demo using SCREEN('DrawDots') subfunction
% author: Keith Schneider, 12/13/04
%                   In this version, compared to DotDemo.m some changes were made so that the
%                   dots are re-arranged differently after they move out of
%                   the display region

%HISTORY
%
% mm/dd/yy
%
% 12/13/04  kas     Wrote it.
% 1/11/05   awi     Merged into Psychtoolbox.org distribution.
%                      -Changed name from "dot_demo" to "DotDemo" to match
%                      Psychtooblox conventions.
%                      -Changed calls to "Screen" from "SCREEN" to avoid
%                      case warning.
%                      -Added HISTORY section to comments.
% 1/13/05   awi     Merged in Mario Kleiner's modifications to agree with
%                   his changes to Screen 'DrawDots' and also time performance:
%                      -Increases number of dots (ndots) by 10x
%                      -Decreases width dot (dot_w) from 0.3 to 0.1
%                      -Changed the 'OpenWindow' call to specify double
%                       buffers for onscreen window and 32-bit depth
%                      -Transpose second argument to Screen 'DrawDots'.
%                       Mario interchanged x&y matrix axes in this 'DrawDots'
%                       argument because it allows a direct copy from a MATLAB matrix
%                       into an OpenGL structure, without memory reordering, which
%                       is slow.  This is controversial because the Psychtoolbox
%                       uniformly interprets matrix M axis (rows) as screen Y axis and
%                       matrix N (columns) as screen N axis.  This change breaks that
%                       convention.
%                      -Add calls to GetSeccs to time performance.
% 3/22/05   mk      Added code to show how to specify different color and
%                   size for each single dot.
% 4/23/05   mk      Add call to Screen('BlendFunction') to reenable
%                   point-smoothing.
% 4/23/05   fwc     changed color and size specifications to use 'rand',
%                   rather than 'random'
%                   differentsizes is now max size value for random size
%                   assigment. Decrease nr of dots when differentsizes>0
%                   added option to break out of loop by pressing key or
%                   mouse button.
%                   Will now default to max of screens rather than main
%                   screen.
% 5/31/05   mk      Some modifications to use new Flip command...
% 07/01/07  fwc     added option differentcolors=2 to have different dot color for in and
%                   outward moving dots. Added commandwindow command at
%                   beginning. re-enabled try-catch. Added WaitSecs to
%                   loop.
%                   further adapted so that dot density for each colour
%                   remains same
%                   In this version, compared to DotDemo.m some changes were made so that the
%                   dots are re-arranged differently after they move out of
%                   the display region

AssertOpenGL;
commandwindow;
% try

% ------------------------
% set dot field parameters
% ------------------------

nframes     = 5000; % number of animation frames in loop
mon_width   = 39;   % horizontal dimension of viewable screen (cm)
v_dist      = 60;   % viewing distance (cm)
dot_speed   = 3;    % dot speed (deg/sec)
ndots       = 2000; % number of dots
max_d       = 15;   % maximum radius of  annulus (degrees)
min_d       = 2;    % minumum
dot_w       = 0.25;  % width of dot (deg)
fix_r       = 0.15; % radius of fixation point (deg)
f_kill      = 0.03; % fraction of dots to kill each frame (limited lifetime)
differentcolors =2; % Use a different color for each point if == 1. Use common color white if == 0. Use 2 for half white, half black dots
differentsizes = 0; % Use different sizes for each point if >= 1. Use one common size if == 0.
waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh.

if differentsizes>0  % drawing large dots is a bit slower
    ndots=round(ndots/2);
end

% ---------------
% open the screen
% ---------------

doublebuffer=1;
screens=Screen('Screens');
screenNumber=max(screens);
% [w, rect] = Screen('OpenWindow', screenNumber, 0,[1,1,801,601],[], doublebuffer+1);
[w, rect] = Screen('OpenWindow', screenNumber, 0,[],[], doublebuffer+1);

% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[center(1), center(2)] = RectCenter(rect);
fps=Screen('FrameRate',w);      % frames per second
ifi=Screen('GetFlipInterval', w);
if fps==0
    fps=1/ifi;
end;

black = BlackIndex(w);
white = WhiteIndex(w);
gray=GrayIndex(w);
% gray background with black and white dots, otherwise black background
if (differentcolors==2)
    Screen('FillRect', w, gray)
else
    Screen('FillRect', w, black)
end
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(w));

% Do initial flip...
vbl=Screen('Flip', w);

% ---------------------------------------
% initialize dot positions and velocities
% ---------------------------------------

ppd = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
pfs = dot_speed * ppd / fps;                            % dot speed (pixels/frame)
s = dot_w * ppd;                                        % dot size (pixels)
fix_cord = [center-fix_r*ppd center+fix_r*ppd];

rmax = max_d * ppd;	% maximum radius of annulus (pixels from center)
rmin = min_d * ppd; % minimum
r = rmax * sqrt(rand(ndots,1));	% r

while 1
    r_mi=find(r<rmin);
    nmi=length(r_mi);
    if nmi<10
        break
    end
    r(r_mi)=rmax * sqrt(rand(nmi,1));
end
r(r<rmin) = rmin;



t = 2*pi*rand(ndots,1);                     % theta polar coordinate
cs = [cos(t), sin(t)];
xy = [r r] .* cs;   % dot positions in Cartesian coordinates (pixels from center)

mdir = 2 * floor(rand(ndots,1)+0.5) - 1;    % motion direction (in or out) for each dot
dr = pfs * mdir;                            % change in radius per frame (pixels)
dxdy = [dr dr] .* cs;                       % change in x and y per frame (pixels)

% Create a vector with different colors for each single dot, if
% requested:
if (differentcolors==1)
    colvect = round(rand(3,ndots)*255);
elseif (differentcolors==2)
    colvect=ones(1,ndots);
    colvect(find(mdir>0))=0;
    colvect=cat(1, colvect, colvect, colvect); % colors need to have 3 entries
    colvect=colvect*255;
else
    colvect=white;
end;

colvect;

% Create a vector with different point sizes for each single dot, if
% requested:
if (differentsizes>0)
    s=(1+rand(1, ndots)*(differentsizes-1))*s;
end;

buttons=0;

% --------------
% animation loop
% --------------
for i = 1:nframes
    if (i>1)
        Screen('FillOval', w, white, fix_cord);	% draw fixation dot (flip erases it)
        Screen('DrawDots', w, xymatrix, s, colvect, center,1);  % change 1 to 0 to draw square dots
        Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
    end;

    [mx, my, buttons]=GetMouse(screenNumber);
    if KbCheck | find(buttons) % break out of loop
        break;
    end;

    xy = xy + dxdy;						% move dots
    r = r + dr;							% update polar coordinates too

    % check to see which dots have gone beyond the borders of the annuli
    %             r_ch = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	% dots to reposition

    r_mx=find(r > rmax);
    r_mi=find(r < rmin);
    r_ki=find(rand(ndots,1) < f_kill);

    nmax = length(r_mx);
    if nmax>0
        r(r_mx)=rmin+(rmax-rmin)/2*sqrt(rand(nmax,1));
    end
    nmin = length(r_mi);
    if nmin>0
        r(r_mi)=rmax-sqrt(rand(nmin,1));
    end

    nki=length(r_ki);
    if nki>0
        r(r_ki)=rmax* sqrt(rand(nki,1));;
    end


    r_ch=[r_mx; r_mi; r_ki];

    nch = length(r_ch);

    if nch

        % choose new coordinates

        %             r(r_ch) = rmax * sqrt(rand(nch,1));
        r(r<rmin) = rmin;
        t(r_ch) = 2*pi*(rand(nch,1));

        % now convert the polar coordinates to Cartesian

        cs(r_ch,:) = [cos(t(r_ch)), sin(t(r_ch))];
        xy(r_ch,:) = [r(r_ch) r(r_ch)] .* cs(r_ch,:);

        % compute the new cartesian velocities

        dxdy(r_ch,:) = [dr(r_ch) dr(r_ch)] .* cs(r_ch,:);
    end;


    xymatrix = transpose(xy);

    if (doublebuffer==1)
        vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
    end;
    WaitSecs(0.001);  % briefly return control to OS.
end;
Priority(0);
ShowCursor;

WaitSecs(1);

Screen('CloseAll');
% catch
%     Priority(0);
%     ShowCursor
%     Screen('CloseAll');
% end
