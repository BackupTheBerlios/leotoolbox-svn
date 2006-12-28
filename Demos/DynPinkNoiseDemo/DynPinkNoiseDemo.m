function DynPinkNoiseDemo
% DynPinkNoiseDemo
%
% Display a (gaussian masked) pink noise image
% using the Screen('DrawTexture') command.
% Pink noise code "borrowed" from SpatialPattern.m written by Jon
% Yearsley
%
% see also: AlphaImageDemo, SpatialPattern.m

% HISTORY
%
% mm/dd/yy
%
%  11/11/06   fwc     created, based on AlphaImageDemo

clear; % clean up any left over garbage
commandwindow; % move commandwindow to the front

% set the way the texture is masked
maskOption=2; % 0=no masking, 1=add transparency layer, 2=overdraw with maskblob

dd=768/2-1; % image size
    BETA=-3; % noise type (-1=pink, -2=brownian, -3/-4=clouds
    lp=2; % magnification on screen
    repl=0; % replaced random dots in phase map (0 and 100 is completely new image

% Standard coding practice, use try/catch to allow cleanup on error.
try
    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    % Screen is able to do a lot of configuration and performance checks on
    % open, and will print out a fair amount of detailed information when
    % it does.  These commands supress that checking behavior and just let
    % the demo go straight into action.  See ScreenTest for an example of
    % how to do detailed checking.
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    % Say hello in command window
    fprintf('\nDynamic Pink Noise Demo\n');

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screenNumber=max(Screen('Screens'));

    % Open a double buffered fullscreen window and draw a gray background
    % and front and back buffers.
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Find the color values which correspond to white and black.
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    Screen('FillRect',w, gray);
    Screen('Flip', w);

    %     We create a Luminance+Alpha matrix for use as transparency mask:
    %     Layer 1 (Luminance) is filled with luminance value 'gray' of the
    %     background.
    ms=100;
    
    ms=(dd-1)/2;

    transLayer=2;
    [x,y]=meshgrid(-ms:ms, -ms:ms);
    maskblob=uint8(ones(2*ms+1, 2*ms+1, transLayer) * gray);
    size(maskblob)

    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    xsd=ms/2.2;
    ysd=ms/2.2;
    maskblob(:,:,transLayer)=uint8(round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255));

    % create transparancy matrix for later addition to images
    ts=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));

    % Build a single transparency mask texture
    masktex=Screen('MakeTexture', w, maskblob);
    mRect=Screen('Rect', masktex);
    %     fprintf('Size image texture: %d x %d\n', RectWidth(tRect), RectHeight(tRect));
    fprintf('Size  mask texture: %d x %d\n', RectWidth(mRect), RectHeight(mRect));

    % Blank sceen
    Screen('FillRect', w, gray);
    Screen('Flip', w);

    % initialize mouse position at center
    [a,b]=WindowCenter(w);
    SetMouse(a,b,screenNumber);
    HideCursor;
    buttons=0;

    % Bump priority for speed
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    % Generate the grid of frequencies. u is the set of frequencies along the
    % first dimension

    DIM=[dd dd];

    % First quadrant are positive frequencies.  Zero frequency is at u(1,1).
    u = [(0:floor(DIM(1)/2)) -(ceil(DIM(1)/2)-1:-1:1)]'/DIM(1);
    % Reproduce these frequencies along every row
    % u = repmat(u,1,DIM(2));
    % v is the set of frequencies along the second dimension.  For a square
    % region it will be the transpose of u
    % v = [(0:floor(DIM(2)/2)) -(ceil(DIM(2)/2)-1:-1:1)]/DIM(2);
    % Reproduce these frequencies along every column
    % v = repmat(v,DIM(1),1);

    [u v]=meshgrid(u);


    % Generate the power spectrum
    S_f = (u.^2 + v.^2).^(BETA/2);

    % Set any infinities to zero
    S_f(S_f==inf) = 0;

    phi = rand(DIM);
    repl=floor(repl/100*length(phi(:))); % number of pixels to replace

    dRect = CenterRectOnPoint([0 0 DIM(1)*lp DIM(2)*lp], a, b); % determine destination rectangle

    % draw textures
    [h,v]=WindowSize(w);
    radius=v/3;
    [a,b]=WindowCenter(w);

    %     % fixation point
    %     Screen('FillOval', w, [255 0 0], CenterRect([0 0 5 5], wRect));
    %
    % Useful info for user about how to quit.
    Screen('DrawText', w, 'Click mouse to exit.', 20, 20, black);

    % allocate memory for image + transparency layer
    imdata=zeros(dd, dd);
    patt2=zeros(dd, dd);
    % add transparency layer to create smooth edges (option 1 to do
    % this)
    if maskOption==1
        immdata=zeros(dd, dd, 2); % image will go in first layer
        immdata(:,:,transLayer)=ts;
    end

    t=zeros(10000,1);
    i=1;
    % show on screen
    Screen('Flip', w);

    % Main waiting loop
    mxold=0;
    myold=0;
    while (1)
        % We wait a few ms each loop-iteration so that we
        % don't overload the system in realtime-priority:
        WaitSecs(0.003);

        % create random pink noise image
        if repl==100 | repl==0
            % Generate a new grid of random phase shifts
            phi = rand(DIM);
        else % replace part of random phase noise with new noise
            newphi = rand(DIM);
            coo=1+round(rand(1,repl)*(length(phi(:))-1));
            phi(coo)=newphi(coo);
        end

        if maskOption==1 % this variant is about 15% slower than the other
            % due to additional Matlab memory management
            % Inverse Fourier transform to obtain the spatial pattern
            patt = ifft2(S_f.^0.5 .* (cos(2*pi*phi)+i*sin(2*pi*phi)));
            % Pick just the real component
            patt = real(patt);
            % scale for image values to be in the range 0-255
            ma=max(max(patt));
            mi=min(min(patt));
            immdata(:,:,1)=(patt-mi)/(ma-mi)*255;
            % make texture
            mytex=Screen('MakeTexture', w, immdata);

        else % faster variant
            % Pick just the real component
            % Inverse Fourier transform to obtain the spatial pattern
            imdata = ifft2(S_f.^0.5 .* (cos(2*pi*phi)+i*sin(2*pi*phi)));
            imdata = real(imdata);
            % scale for image values to be in the range 0-255
            ma=max(max(imdata));
            mi=min(min(imdata));
            imdata=(imdata-mi)/(ma-mi)*255;
            % make texture
            mytex=Screen('MakeTexture', w, imdata);
        end

        Screen('DrawTexture', w, mytex, [], dRect);

        % overdraw with mask and therefore blend with background (option 2)
        if maskOption==2
            Screen('DrawTexture', w, masktex, [], dRect);
        end
        Screen('Flip', w);

        t(i)=GetSecs;
        i=i+1;
         % get mouse clicks
        [mx, my, buttons]=GetMouse(screenNumber);

        mxold=mx;
        myold=my;

       % Break out of loop on mouse click
        if find(buttons)
            break;
        end
    end

    % The same command which closes onscreen and offscreen windows also
    % closes textures.
    Screen('CloseAll');
    ShowCursor;
    Priority(0);

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

    t=t(find(t>0));
    t=t(5:end);
    tm=mean(diff(t));
    fprintf('Mean noise refresh interval: %.1f ms.\n', tm*1000);

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
catch

    Screen('CloseAll');
    ShowCursor;
    Priority(0);

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

    psychrethrow(psychlasterror);
end
