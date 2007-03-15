function GazePlay
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

dummymode=0; % if 1, we force eyelink software to run in dummy mode.

if 1, Screen('Preference', 'SkipSyncTests', 1); end
commandwindow;

% try
KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
quitKey=KbName('ESCAPE');
modKey=KbName('LeftGUI');

fprintf('%s (%s)\n', mfilename, datestr(now));
fprintf('Press a key to stop demo.\n');

% Set hurryup = 1 for benchmarking - Syncing to retrace is disabled
% in that case so we'll get the maximum refresh rate.
hurryup=0;

mode = 1;
usemodes=[1 2];
maxmode=length(usemodes);
% Setup default aperture size to 2*200 x 2*200 pixels.
% if nargin < 2
%     ms=200;
% end;
ms=200;

imglist={'konijntjes1024x768', 'straat', 'web'};

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
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen
Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 80);
Screen('TextStyle', w, 1);


Screen('FillRect', w, gray);
Screen('Flip', w);

[result dummymode]=EyelinkInit(dummymode);
if result==0
    if dummymode==1
        disp('Could not dummy-initialize eye tracker, experiment stopped');
    else
        disp('Could not initialize eye-tracker, experiment stopped');
    end
    return;
end

% do eyelink stuff
el=EyelinkInitDefaults(w);
el.backgroundcolour=gray;
% make sure that we get gaze data from the Eyelink
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open file to record data to
Eyelink('openfile', 'demo.edf');

HideCursor;
% Set background color to gray:
backgroundcolor = gray;

DrawFormattedText(w, 'Eén moment.....', 'center', 'center', white);
Screen('Flip', w);

for im=1:length(imglist)

    myimgfile=imglist{im};
    myblurimgfile= [myimgfile 'moreblur' '.jpg'];
    myimgfile=[myimgfile '.jpg'];
    % Load image file:
    fprintf('Loading image ''%s''\n', myimgfile);
    imdata=imread(myimgfile);
    imdatablur=imread(myblurimgfile);

    [iy, ix, id]=size(imdata);
    [wW, wH]=WindowSize(w);
    %
    tic
    [imtex(im)]=Screen('OpenOffscreenWindow', w);
    Screen('PutImage', imtex(im), imdata, Screen('Rect', imtex(im)));
    [imblurtex(im)]=Screen('OpenOffscreenWindow', w);
    Screen('PutImage', imblurtex(im), imdatablur, Screen('Rect', imblurtex(im)));
    toc
end
[backtex]=Screen('OpenOffscreenWindow', w, backgroundcolor);
%
clear imdata imdatablur

% We create a Luminance+Alpha matrix for use as transparency mask:
% Layer 1 (Luminance) is filled with 'backgroundcolor'.
transLayer=2;
[x,y]=meshgrid(-ms:ms, -ms:ms);
maskblob=ones(2*ms+1, 2*ms+1, transLayer) * backgroundcolor;

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
% fprintf('Size  mask texture: %d x %d\n', RectWidth(mRect), RectHeight(mRect));
%

goOn=1;

while goOn==1  % continue demo
    commandwindow;
    % The mouse-cursor position will define gaze-position (center of
    % fixation) to simulate (x,y) input from an eyetracker. Set cursor
    % initially to center of screen:
    [a,b]=WindowCenter(w);
    WaitSetMouse(a,b,w); % set cursor and wait for it to take effect
    Screen('BlendFunction', w,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending

    goOn=showInstruction(w);

    %    Screen('TextFont',w, 'Arial');
    %     Screen('TextSize',w, 80);
    %     Screen('TextStyle', w, 1);




    % Calibrate the eye tracker
    if dummymode==0
        DrawFormattedText(w, 'Nu eerst calibreren...\nVraag om assistentie!', 'center', 'center', white);
        Screen('Flip', w);
        WaitSecs(3);
        EyelinkDoTrackerSetup(el);

        % do a final check of calibration using driftcorrection
%         EyelinkDoDriftCorrection(el);
        WaitSecs(0.1);
    end
    Eyelink('StartRecording');

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end


    % Find the color values which correspond to white and black.  Though on OS
    % X we currently only support true color and thus, for scalar color
    % arguments,
    % black is always 0 and white 255, this rule is not true on other platforms will
    % not remain true on OS X after we add other color depth modes.
    Screen('TextFont',w, 'Arial');
    Screen('TextSize',w, 80);
    Screen('TextStyle', w, 1);



    %
    % Set background color to 'backgroundcolor' and do initial flip to show
    % blank screen:
    Screen('FillRect', w, backgroundcolor);
    Screen('Flip', w);


    priorityLevel=MaxPriority(w);
    oldPriority=Priority(priorityLevel);

    % Wait until all keys on keyboard are released:
    while KbCheck; WaitSecs(0.1); end;
    disp('start');


    mx=0;
    my=0;
    mxold=0;
    myold=0;
    firstTime=1;
    tavg = 0;
    ncount = 0;
    newmode=0;
    alpha=255;
    athres=160;
    removeDescr=0;
    mode=1;
    im=0;
    decAlphaTime=0;

    Screen('FillRect', w, backgroundcolor);
    oldvbl=Screen('Flip', w);

    % Infinite display loop: Whenever "gaze position" changes, we update
    % the display accordingly. Loop aborts on keyboard press or mouse
    % click or after 10000 frames...
    while (ncount < 10000 && goOn==1)

        [kx, ky, buttons]=GetMouse(w);

        if firstTime==1 || any(buttons)
            im=im+1;
            if im>length(imglist)% if we cycled through the images, we move on to the next field defect
                im=1;
                mode=mode+1;
                if mode>maxmode
                    mode=1;
                    break
                end
                alpha=255;
                decAlphaTime=GetSecs+5;
            end
            %                 tic
            [foveatex, peritex, descriptor]=selectTextures(usemodes(mode), imtex(im), imblurtex(im), backtex);
            [resident texidresident] = Screen('PreloadTextures', w , [masktex, foveatex, peritex, backtex]);
            %                 toc

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
            removeDescr=0;
        end


        %         Eyelink('IsConnected')
        if Eyelink('IsConnected')==el.connected
            error=Eyelink('CheckRecording');
            if(error~=0)
                goOn=0;
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
            goOn=0;
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

                    if GetSecs>decAlphaTime
                        alpha=round(alpha*0.99);
                    end
                    if alpha<=athres
                        removeDescr=1;
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
        end

        % Keep track of last gaze position:
        mxold=mx;
        myold=my;

        % We wait 1 ms each loop-iteration so that we
        % don't overload the system in realtime-priority:
        WaitSecs(0.001);

        % Abort demo on keypress

        [keyIsDown, secs, keyCode] = KbCheck();

        if keyCode(modKey)==1 && keyCode(quitKey)==1
            goOn=0
            break;

        elseif keyIsDown % break out of loop
            fprintf('User break out of loop\n');
            break;
        end


    end
    Screen('FillRect', w, backgroundcolor);
    Screen('Flip', w);

    Priority(oldPriority);

    % stop eyelink
    Eyelink('StopRecording');
    Eyelink('message', 'TRIAL END');

    Screen('TextFont',w, 'Arial');
    Screen('TextSize',w, 80);
    Screen('TextStyle', w, 1);
    DrawFormattedText(w, 'Demonstratie is klaar,\ntot ziens!', 'center', 'center', white);
    Screen('Flip', w);
    WaitSecs(3);
    Screen('FillRect', w, backgroundcolor);
    Screen('Flip', w);
end
Eyelink('ShutDown');

% Display full image a last time, just for fun...
% Screen('BlendFunction', w, GL_ONE, GL_ZERO);
% Screen('DrawTexture', w, imtex);
% Screen('Flip', w);
% WaitSecs(1);
% The same command which closes onscreen and offscreen windows also
% closes textures.
Screen('CloseAll');
ShowCursor;
Priority(oldPriority);
tavg = tavg / ncount * 1000;
% fprintf('End of %s. Avg. redraw time is %f ms = %f Hz.\n\n', mfilename, tavg, 1000 / tavg);
home
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

function [foveatex, peritex, descr]=selectTextures(mode, imtex, imblurtex, backtex)


% select image for foveated region and periphery:
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


function goOn=showInstruction(window)
goOn=1;
% show instruction on screen
% Screen is erased before returning.
goOn=1;
tstring=['Dit simulatie programma\n'];
tstring=[tstring 'geeft een indruk van\n'];
tstring=[tstring 'de gevolgen van\n'];
tstring=[tstring 'een gezichtsveld-defect\n'];
tstring=[tstring 'voor het zien.\n\n'];
tstring=[tstring 'Druk op een muisknop om\n'];
tstring=[tstring 'verschillende defecten\n'];
tstring=[tstring 'te ervaren.\n\n\n'];
tstring=[tstring 'Druk nu op een knop om verder te gaan.\n'];


Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 40);
Screen('TextStyle', window, 1);


% this is a handy function provided by the PsychToolbox for
% drawing nicely formatted and centered (if required) text.
% see its help for all options
% DrawFormattedText(window, tstring, 'center', 'center', WhiteIndex(window));
DrawFormattedText(window, tstring, 200, 'center', WhiteIndex(window));
Screen('Flip', window);

% wait for key release
while KbCheck
    WaitSecs(0.01);
end
quitKey=KbName('ESCAPE');
modKey=KbName('LeftGUI');

keyIsDown=0;
% wait for key press
while keyIsDown==0
    [keyIsDown,secs,keyCode] = KbCheck;
    [kx, ky, buttons]=GetMouse;
    if any(buttons), break, end

    % test if the user wanted to stop
    if keyCode(quitKey) && keyCode(modKey)
        display('User requested break');
        goOn=0;
        break;
    end
    WaitSecs(0.01);
end

% erase the instruction screen
Screen('FillRect', window, GrayIndex(window));
Screen('Flip', window);




    