 function TextureDemo
% TextureeDemo
%
% Display a gaussian masked image, locked to the cursor position,
% using the Screen('DrawTexture') command.
%
% This illustrates an application of OpenGL Alpha blending by displaying
% an image masked with a gaussian transparency mask.
%
% In each frame, first the image is drawn. Then a texture acting as a
% transparency mask is drawn "over" the image, leaving only selected
% parts of the image.
%
% Please note that we only use two textures: One holding the image,
% the other defining the mask.
%
% see also: PsychDemos, MovieDemo, DriftDemo

% HISTORY
%
% mm/dd/yy
%
%  6/28/04    awi     Adapted from Denis Pelli's DriftDemo.m for OS 9
%  7/18/04    awi     Added Priority call.  Fixed.
%  9/8/04     awi     Added Try/Catch, cosmetic changes to comments and see also.
%  1/4/05     mk      Adapted from awi's DriftDemoOSX.
%  24/1/05    fwc     Adapted from AlphaImageDriftDemoOSX, bug in
%                     drawtexture prevents it from doing what I really want
%  28/1/05    fwc     Yeah, works great now after bug was removed from
%                     drawtexture by mk, cleaned up code
%  02/07/05   fwc     slightly simplified demo by removing some options
%                       such as automode
%  3/30/05    awi     Added 'BlendFunction' call to set alpha blending mode
%                     The default alpha blending mode for Screen has
%                     changed, this added call sets it to the previous
%                     default.
%  4/23/05    mk      Small modifications to make it compatible with
%                     "normal" Screen.mexmac.
%  12/31/05   mk      Small modifications to make it compatible with Matlab-5
%  10/14/06   dhb     Rename without OSX bit.  Fewer warnings.
%             dhb     More comments, cleaned.

clear;
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
    fprintf('\nTextureDemo\n');

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
    ms=100;
    transLayer=2;
    [x,y]=meshgrid(-ms:ms, -ms:ms);
    xsd=ms/2.2;
    ysd=ms/2.2;
    mask=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));
    
    % Import images and and convert them, stored in
    % MATLAB matrix, into Psychtoolbox OpenGL texture using 'MakeTexture';
    % Set up texture and rects, add transparency mask

    mytexdir='images';
    d=dir(mytexdir);
    first=1;
    j=1;
    for i=1:length(d)
        if d(i).isdir==0 & strcmp(d(i).name(end-3:end), '.jpg')==1
            myimgfile=[mytexdir filesep d(i).name ];
            fprintf('Using image ''%s''\n', myimgfile);
            imdata=imread(myimgfile, 'jpg');
            
            % we add a transparancy layer to each of the images.
            
            imdata(:,:,transLayer)=mask;
            
            mytex(j)=Screen('MakeTexture', w, imdata);
            j=j+1;
        end
    end


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

    % draw textures
    [h,v]=WindowSize(w);
    radius=v/3;
    [a,b]=WindowCenter(w);

    step=360/length(mytex);
    i=1;

    for angle=0:step:359.9
        xr=a+radius*sin(angle/180*pi);     % determine position of patch on circle
        yr=b+radius*cos(angle/180*pi);

        tRect=Screen('Rect', mytex(i)); % get texture rectangle
        dRect = CenterRectOnPoint(tRect, xr, yr); % determine destination rectangle
        % Draw image on destination position
        Screen('DrawTexture', w, mytex(i), tRect, dRect);
%         % Overdraw -- and therefore alpha-blend -- with gaussian alpha mask
%         Screen('DrawTexture', w, masktex, [], dRect);
        i=i+1;
    end
    % fixation point
    Screen('FillOval', w, [255 0 0], CenterRect([0 0 5 5], wRect));

    % Useful info for user about how to quit.
    Screen('DrawText', w, 'Click mouse to exit.', 20, 20, black);
    
    % show on screen
    Screen('Flip', w);

    % Main waiting loop
    mxold=0;
    myold=0;
    while (1)
        % We wait at least 10 ms each loop-iteration so that we
        % don't overload the system in realtime-priority:
        WaitSecs(0.01);

        % We only redraw if mouse has been moved:
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
