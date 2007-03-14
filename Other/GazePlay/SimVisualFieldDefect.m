function GazePlay(myimgfile)
%
% OS X: ___________________________________________________________________
%
% Demo implementation of a generic gaze-contingent display.
% We take one input image and create - via image processing - two images
% out of it: An image to show at the screen location were the subject
% fixates (According to the eye-tracker). A second image to show in the
% peripery of the subjects field of view. These two images are blended into
% each other via a gaussian weight mask (an aperture). The mask is centered
% at the center of gaze and allows for a smooth transition between the two
% images.
% in this instance, upon keypress, we loop through the different modes
% modes: 1, tunnel vision, 2 macular degeneration,
%        3, foveal blur, 4 peripheral blur,
%        5, foveal gray, 6 peripheral gray
%        7, Foveal color-inversion, 8, peripheral color-inversion
%        9 test case

% This illustrates an application of OpenGL Alpha blending by compositing
% two images based on a spatial gaussian weight mask. Compositing is done
% by the graphics hardware.
%
%
% OS 9 : ______________________________________________________
%
% GazePlay does not exist on OS 9.
% _________________________________________________________________________
%
% see also: PsychDemosOSX, MovieDemoOSX, DriftDemo

% HISTORY
%
% mm/dd/yy
%
%  7/23/05    mk      Derived it from Frans Cornelissens AlphaImageDemoOSX.
%   29/06/06  fwc     Derived from Mario Kleiner's GazeContingentDemoOSX ;-)
%   13/03/07  fwc     Added a few more modes, let it run (again) without a
%                       tracker, loop through modes

dummymode=1; % if 1, we force eyelink software to run in dummy mode.

if 1, Screen('Preference', 'SkipSyncTests', 1); end
commandwindow;


% Set hurryup = 1 for benchmarking - Syncing to retrace is disabled
% in that case so we'll get the maximum refresh rate.
hurryup=0;

% Setup default mode to color vs. gray.
% if nargin < 1
%     mode = 1;
% end;
mode = 1;
usemodes=[1 3 2];
maxmode=length(usemodes);
% Setup default aperture size to 2*200 x 2*200 pixels.
% if nargin < 2
%     ms=200;
% end;
ms=200;
% Use default demo images, if no special image was provided.
if nargin < 1
    myimgfile= 'konijntjes1024x768';
end;

myblurimgfile= [myimgfile 'moreblur.jpg'];
mygrayimgfile= [myimgfile 'gray.jpg'];


myimgfile=[myimgfile '.jpg'];
% try
fprintf('GazeContingentDemo (%s)\n', datestr(now));
fprintf('Press a key or click on mouse to stop demo.\n');

% initialize eyelink
%     if EyelinkInit()~= 1; %
%         return;
%     end;
%
[result dummymode]=EyelinkInit(dummymode);
if result==0
    if dummymode==1
        disp('Could not dummy-initialize eye tracker, experiment stopped');
    else
        disp('Could not initialize eye-tracker, experiment stopped');
    end
    return;
end

% This script calls Psychtoolbox commands available only in OpenGL-based
% versions of the Psychtoolbox. The Psychtoolbox command AssertOpenGL will issue
% an error message if someone tries to execute this script on a computer without
% an OpenGL Psychtoolbox.
AssertOpenGL;

% Get the list of screens and choose the one with the highest screen number.
% Screen 0 is, by definition, the display with the menu bar. Often when
% two monitors are connected the one without the menu bar is used as
% the stimulus display.  Chosing the display with the highest display number is
% a best guess about where you want the stimulus displayed.
screenNumber=max(Screen('Screens'));

% Open a double buffered fullscreen window.
[w, wRect]=Screen('OpenWindow',screenNumber);

% Find the color values which correspond to white and black.  Though on OS
% X we currently only support true color and thus, for scalar color
% arguments,
% black is always 0 and white 255, this rule is not true on other platforms will
% not remain true on OS X after we add other color depth modes.
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen

Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 80);
Screen('TextStyle', w, 1);



% Set background color to gray:
backgroundcolor = gray;

% Load image file:
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imdatablur=imread(myblurimgfile);
imdatagray=imread(mygrayimgfile);

%     crop image if it is larger then screen size. There's no image scaling
%     in maketexture
[iy, ix, id]=size(imdata);
[wW, wH]=WindowSize(w);
% wW=wRect(3);
% wH=wRect(4);
% if ix>wW || iy>wH
%     disp('Image size exceeds screen size');
%     disp('Image will be cropped');
% end
% 
% if ix>wW
%     cl=round((ix-wW)/2);
%     cr=(ix-wW)-cl;
% else
%     cl=0;
%     cr=0;
% end
% if iy>wH
%     ct=round((iy-wH)/2);
%     cb=(iy-wH)-ct;
% else
%     ct=0;
%     cb=0;
% end
% 
% % imdata is the cropped version of the image.
% imdata=imdata(1+ct:iy-cb, 1+cl:ix-cr,:);
% imdatablur=imdatablur(1+ct:iy-cb, 1+cl:ix-cr,:);
% imdatagray=imdatagray(1+ct:iy-cb, 1+cl:ix-cr,:);
% 
tic
[imtex]=Screen('OpenOffscreenWindow', w);
Screen('PutImage', imtex, imdata, Screen('Rect', imtex));
% imtex=Screen('MakeTexture', w, imdata);

[imblurtex]=Screen('OpenOffscreenWindow', w);
Screen('PutImage', imblurtex, imdatablur, Screen('Rect', imblurtex));

% imblurtex=Screen('MakeTexture', w, imdatablur);

[imgraytex]=Screen('OpenOffscreenWindow', w);
Screen('PutImage', imgraytex, imdatagray, Screen('Rect', imgraytex));
% imgraytex=Screen('MakeTexture', w, imdatagray);

[iminvtex]=Screen('OpenOffscreenWindow', w);
Screen('PutImage', iminvtex, 255-imdata(:,:,:), Screen('Rect', iminvtex));
% iminvtex=Screen('MakeTexture', w, 255-imdata(:,:,:));

[backtex]=Screen('OpenOffscreenWindow', w, backgroundcolor);
toc
% imdata(:,:,:)=backgroundcolor;
% backtex=Screen('MakeTexture', w, imdata);
% 
clear imdata imdatablur imdatagray

% We create a Luminance+Alpha matrix for use as transparency mask:
% Layer 1 (Luminance) is filled with 'backgroundcolor'.
transLayer=2;
[x,y]=meshgrid(-ms:ms, -ms:ms);
maskblob=ones(2*ms+1, 2*ms+1, transLayer) * backgroundcolor;
% Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
% mask.
% xsd=ms/2.2;
% ysd=ms/2.2;
% maskblob(:,:,transLayer)=round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255);


        % dist from center
        d=sqrt(x.^2+y.^2);
        pp=4; % 4 gives sharper edge
        dm=0; % center
        dsd=ms/1.5; % looks okay, empirically
        maskblob(:,:,transLayer)=round(white-exp(-((d-dm)/dsd).^pp)*white);

% Build a single transparency mask texture:
masktex=Screen('MakeTexture', w, maskblob);
mRect=Screen('Rect', masktex);

%     fprintf('Size image texture: %d x %d\n', RectWidth(tRect), RectHeight(tRect));
    fprintf('Size  mask texture: %d x %d\n', RectWidth(mRect), RectHeight(mRect));
%
%
% Set background color to 'backgroundcolor' and do initial flip to show
% blank screen:
Screen('FillRect', w, backgroundcolor);
Screen('Flip', w);


% do eyelink stuff
el=EyelinkInitDefaults(w);

% make sure that we get gaze data from the Eyelink
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
Eyelink('openfile', 'demo.edf');

% STEP 4
% Calibrate the eye tracker
if dummymode==0
    EyelinkDoTrackerSetup(el);

    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    WaitSecs(0.1);
end
Eyelink('StartRecording');

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

% Set background color to 'backgroundcolor' and do initial flip to show
% blank screen:
Screen('FillRect', w, backgroundcolor);
Screen('Flip', w);


% The mouse-cursor position will define gaze-position (center of
% fixation) to simulate (x,y) input from an eyetracker. Set cursor
% initially to center of screen:
[a,b]=WindowCenter(w);
WaitSetMouse(a,b,w); % set cursor and wait for it to take effect

    HideCursor;

priorityLevel=MaxPriority(w);
oldPriority=Priority(priorityLevel);

% Wait until all keys on keyboard are released:
while KbCheck; WaitSecs(0.1); end;

mxold=0;
myold=0;
firstTime=1;
tavg = 0;
ncount = 0;
newmode=0;
alpha=0;
athres=160;
removeDescr=0;
mode=0;
[resident texidresident] = Screen('PreloadTextures', w , [masktex, imtex, imblurtex, backtex, imgraytex, iminvtex]);


disp('start');
oldvbl=Screen('Flip', w);

% Infinite display loop: Whenever "gaze position" changes, we update
% the display accordingly. Loop aborts on keyboard press or mouse
% click or after 10000 frames...
while (ncount < 10000)

    [kx, ky, buttons]=GetMouse(w);

    if firstTime==1 || any(buttons)
        mode=mode+1;
        if mode>maxmode
            mode=1;
        end
%         tic
        [foveatex, peritex, descriptor]=selectTextures(usemodes(mode), imtex, imblurtex, imgraytex, iminvtex, backtex);
%         toc

        tRect=Screen('Rect', foveatex);
        [ctRect, dx, dy]=CenterRect(tRect, wRect);
        pRect=Screen('Rect', peritex);
%         fprintf('Size foveal image texture: %d x %d\n', RectWidth(tRect), RectHeight(tRect));
%         fprintf('Size peripherhal image texture: %d x %d\n', RectWidth(pRect), RectHeight(pRect));
% 
        firstTime=0;
%         tic
        while any(buttons)
            [kx, ky, buttons]=GetMouse(w);
            WaitSecs(0.01);
        end
%         toc
        newmode=0;
        alpha=255;
        removeDescr=0;
    end


    %         Eyelink('IsConnected')
    if Eyelink('IsConnected')==el.connected
        error=Eyelink('CheckRecording');
        if(error~=0)
            break;
        end

        if Eyelink( 'NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink( 'NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = evt.gy(eye_used+1);
                % do we have valid data and is the pupil visible?
                if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0

                    mx=x;
                    my=y;
                end
            end
        end
    elseif Eyelink('IsConnected')==el.dummyconnected

        % Query current mouse cursor position (our "dummy-eyetracker") -
        % (mx,my) is our gaze position.
        if (hurryup==0)
            mx=kx;
            my=ky;
        else
            % In benchmark mode, we just do a quick sinusoidal motion
            % without query of the mouse:
            mx=500 + 500*sin(ncount/10); my=300;
        end;
    else
        Disp('Eyelink disconnected');
        break;
    end

    % We only redraw if gazepos. has changed:
    if (mx~=mxold || my~=myold || alpha>athres || removeDescr==1)
        %             disp('(mx~=mxold || my~=myold)');
        % Compute position and size of source- and destinationrect and
        % clip it, if necessary...
        myrect=[mx-ms my-ms mx+ms+1 my+ms+1]; % center dRect on current mouseposition
        dRect = ClipRect(myrect,ctRect);
        sRect=OffsetRect(dRect, -dx, -dy);
        % Valid destination rectangle?
        if ~IsEmptyRect(dRect) || alpha>athres || removeDescr==1
            if newmode==1
            tic
            end
            if removeDescr==1;
                 Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
                 Screen('DrawTexture', w, peritex, [], ctRect);
                 removeDescr=0;
            end
            % Yes! Draw image for current frame:
            % Step 1: Draw the alpha-mask into the backbuffer. It
            % defines the aperture for foveation: The center of gaze
            % has zero alpha value. Alpha values increase with distance from
            % center of gaze according to a gaussian function and
            % approach 255 at the border of the aperture...
            Screen('BlendFunction', w, GL_ONE, GL_ZERO);
            Screen('DrawTexture', w, masktex, [], myrect);

            % Step 2: Draw peripheral image. It is only drawn where
            % the alpha-value in the backbuffer is 255 or high, leaving
            % the foveated area (low or zero alpha values) alone:
            % This is done by weighting each color value of each pixel
            % with the corresponding alpha-value in the backbuffer
            % (GL_DST_ALPHA).
            Screen('BlendFunction', w, GL_DST_ALPHA, GL_ZERO);
            Screen('DrawTexture', w, peritex, [], ctRect);

            % Step 3: Draw foveated image, but only where the
            % alpha-value in the backbuffer is zero or low: This is
            % done by weighting each color value with one minus the
            % corresponding alpha-value in the backbuffer
            % (GL_ONE_MINUS_DST_ALPHA).
            Screen('BlendFunction', w, GL_ONE_MINUS_DST_ALPHA, GL_ONE);
            Screen('DrawTexture', w, foveatex, sRect, dRect);
            if newmode==1
            toc
            newmode=0;
            end

            if alpha>athres
                Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
                DrawFormattedText(w, descriptor, 'center', 'center', [255 255 255 alpha]);
                alpha=round(alpha*0.995);
                if alpha<=athres
                    removeDescr=1
                end
            end
            
            % Show final result on screen. This also clears the drawing
            % surface back to black background color and a zero alpha
            % value.
            % Actually... We use clearmode=2: This doesn't clear the
            % backbuffer, but we don't need to clear it for this kind
            % of stimulus and it gives us 2 msecs extra headroom for
            % higher refresh rates! For benchmark purpose, we disable
            % syncing to retrace if hurryup is == 1.
            vbl = Screen('Flip', w, 0, 2, 2*hurryup);
            %                 vbl = GetSecs;
            tavg = tavg + (vbl-oldvbl);
            oldvbl=vbl;
            ncount = ncount + 1;
        end;
    end;

    % Keep track of last gaze position:
    mxold=mx;
    myold=my;

    % We wait 1 ms each loop-iteration so that we
    % don't overload the system in realtime-priority:
    WaitSecs(0.001);

    % Abort demo on keypress
    if KbCheck % break out of loop
        break;
    end;


end;

% stop eyelink
Eyelink('StopRecording');
Eyelink('ShutDown');

% Display full image a last time, just for fun...
Screen('BlendFunction', w, GL_ONE, GL_ZERO);
Screen('DrawTexture', w, imtex);
Screen('Flip', w);
WaitSecs(1);
% The same command which closes onscreen and offscreen windows also
% closes textures.
Screen('CloseAll');
ShowCursor;
Priority(oldPriority);
tavg = tavg / ncount * 1000;
fprintf('End of GazeContingentDemo. Avg. redraw time is %f ms = %f Hz.\n\n', tavg, 1000 / tavg);
return;
% catch
%     %this "catch" section executes in case of an error in the "try" section
%     %above.  Importantly, it closes the onscreen window if its open.
%     Eyelink('ShutDown');
%     Screen('CloseAll');
%     ShowCursor;
%     Priority(0);
%     %     psychrethrow(lasterror);
% end %try..catch..

function [foveatex, peritex, descr]=selectTextures(mode, imtex, imblurtex, imgraytex, iminvtex, backtex)


% Compute image for foveated region and periphery:
switch (mode)
    case 1
        % Tunnel Vision, Fovea contains image data, background gray
        foveatex=imtex;
        % Periphery contains gray-version:
        peritex = backtex;
        descr='Kokerzien';
    case 2
        % MD, periphery contains original image data, fovea gray
        foveatex=backtex;
        % Periphery contains gray-version:
        peritex = imtex;
        descr='Macula-gat';
    case 3
        % Fovea contains blurred image data:
        foveatex=imblurtex;
        % Periphery contains gray-version:
        peritex = imtex;
        descr='Macula degeneratie';
    case 4
        % Fovea contains original image data:
        foveatex = imtex;
        % Periphery contains blurred-version:
        peritex = imblurtex;
        descr='Perifere waas';
    case 5
        % Periphery contains original image data:
        foveatex = imtex;
        % Periphery contains grayscale-version:
        peritex = imgraytex;
        descr='Centraal kleur';
    case 6
        % Fovea contains grayscale image data:
        foveatex = imgraytex;
        % Periphery contains original-version:
        peritex = imtex;
        descr='Centraal grijs';
    case 7
        % Fovea contains color-inverted image data:
        foveatex = iminvtex;
        % Periphery contains original data:
        peritex = imtex;
        descr='Centrale kleur inversie';
    case 8
        % Periphery contains color-inverted image data:
        foveatex = imtex;
        % Periphery contains original data:
        peritex =  iminvtex;
        descr='Perifere kleur inversie';
    case 9
        % Test-case: One shouldn't see any foveated region on the
        % screen - this is a basic correctness test for blending.
        foveatex = imtex;
        peritex = imtex;
        descr='Test';
    otherwise
        % Unknown mode! We force abortion:
        fprintf('Invalid mode provided!');
        abortthisbeast
end;

return

% function [foveaimdata, peripheryimdata]=getImData(mode, imdata, imdatablur, imdatagray, backgroundcolor)
% 
% 
% % Compute image for foveated region and periphery:
% switch (mode)
%     case 1
%         % Tunnel Vision, Fovea contains image data, background gray
%         foveaimdata=imdata;
%         % Periphery contains original-version:
%         peripheryimdata = imdata;
%         peripheryimdata(:,:,:) = backgroundcolor;
%     case 2
%         % MD, periphery contains original image data, fovea gray
%         foveaimdata = imdata;
%         foveaimdata(:,:,:) = backgroundcolor;
%         % Periphery contains blurred-version:
%         peripheryimdata=imdata;
%     case 3
%         % Fovea contains blurred image data:
%         foveaimdata = imdatablur;
%         % Periphery contains original-version:
%         peripheryimdata = imdata;
%     case 4
%         % Fovea contains original image data:
%         foveaimdata = imdata;
%         % Periphery contains blurred-version:
%         peripheryimdata = imdatablur;
%     case 5
%         % Periphery contains original image data:
%         foveaimdata = imdata;
%         % Periphery contains grayscale-version:
%         peripheryimdata = imdatagray;
%     case 6
%         % Fovea contains grayscale image data:
%         foveaimdata = imdatagray;
%         % Periphery contains original-version:
%         peripheryimdata = imdata;
%     case 7
%         % Fovea contains color-inverted image data:
%         foveaimdata(:,:,:) = 255 - imdata(:,:,:);
%         % Periphery contains original data:
%         peripheryimdata = imdata;
%     case 8
%         % Periphery contains color-inverted image data:
%         foveaimdata(:,:,:) = imdata;
%         % Periphery contains original data:
%         peripheryimdata =  255 - imdata(:,:,:);
%     case 9
%         % Test-case: One shouldn't see any foveated region on the
%         % screen - this is a basic correctness test for blending.
%         foveaimdata = imdata;
%         peripheryimdata = imdata;
%     otherwise
%         % Unknown mode! We force abortion:
%         fprintf('Invalid mode provided!');
%         abortthisbeast
% end;
% 

    