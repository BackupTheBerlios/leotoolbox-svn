function SyntexDemo
% SyntexDemo
%
% Display a series of texture images, and measure a response.
%
% Also illustrates an application of OpenGL Alpha blending by displaying
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
% 15/11/06  fwc     adapted from texturedemo



clear;
commandwindow;
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

    Screen('FillRect', w, gray);
    Screen('Flip', w);

    % We create a Luminance+Alpha matrix for use as a transparency mask:
    ms=100;
    transLayer=2;
    [x,y]=meshgrid(-ms:ms, -ms:ms);
    mask=uint8(ones(2*ms+1, 2*ms+1, transLayer) * gray); % set colour of texture to background

    xsd=ms/2.2;
    ysd=ms/2.2;
    %     mask=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*255));

    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    mask(:,:,transLayer)=uint8(round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255));

    % Build a single transparency mask texture
    masktex=Screen('MakeTexture', w, mask);
    mRect=Screen('Rect', masktex);
    %     fprintf('Size image texture: %d x %d\n', RectWidth(tRect), RectHeight(tRect));
    fprintf('Size  mask texture: %d x %d\n', RectWidth(mRect), RectHeight(mRect));

    % Import images and and convert them, stored in
    % MATLAB matrix, into Psychtoolbox OpenGL texture using 'MakeTexture';
    % Set up texture and rects, add transparency mask

    first=1;
    present=2;
    mytexdir='images';
    imglist=getImageListFromDir(mytexdir, present);

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



    [h,v]=WindowSize(w);
    [a,b]=WindowCenter(w);

    stopKey=KbName('ESCAPE');

    posKey=KbName('RightArrow');
    negKey=KbName('LeftArrow');
    posKey=KbName('m');
    negKey=KbName('n');
    posResp='pos';
    negResp='neg';
    magn=2;
    response='no response';
    rt=-9999999;
    maxNrPresentations=3;
    pres=0;
    p=0;
    trial=0;
    mask2=[];
    % wait until keyboard is released
    waitForKeyBoardRelease;

    fprintf('Image\tResponse\tRT\n');
    stop=0;
    t1=GetSecs;
    t0=GetSecs;
    % Main  loop
    while stop==0
        %         fprintf('loop took %.1f ms\n\n', (GetSecs-t0)*1000);
        t0=GetSecs;

        p=p+1;
        % if presentation nr equals length stim list, we're done with this round
        if p>length(imglist) | pres==0
            % get (new) random list of image nrs
            if pres<maxNrPresentations
                order=randperm(length(imglist));
                pres=pres+1;
                p=1;
            else
                % we're done with the experiment
                break;
            end
        end
        trial=trial+1;
        imgnr=order(p);
        mess=sprintf('Trial #%d, iter #%d, pres #%d, image #%d.\n', trial, pres, p, imgnr);


        %         fprintf('t1 loop took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;
        % load image and convert to texture
        imgtex=imageToTex(imglist(imgnr).name, w, mask2);
        %         tRect=Screen('Rect', imgtex)

        %         fprintf('image to tex took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;

        dRect = CenterRectOnPoint(Screen('Rect', imgtex)*magn, a, b);

        Screen('DrawTexture', w, imgtex, [], dRect);
        % Overdraw -- and therefore alpha-blend -- with gaussian alpha mask
        Screen('DrawTexture', w, masktex, [], dRect);

        %         fprintf('draw tex took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;


        % fixation point
        Screen('FillOval', w, [255 0 0], CenterRect([0 0 5 5], wRect));

        % Useful info for user about how to quit.
        Screen('DrawText', w, mess, 20, 20, black);
        Screen('DrawText', w, 'Click mouse to exit.', 20, 50, black);

        %         fprintf('draw text took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;


        % wait until keyboard is released
        t=waitForKeyBoardRelease;

        % show on screen

        if t>1
        fprintf('oops, wait until keyboard is released took %.1f ms\n', (t)*1000);
        end
        t1=GetSecs;


        Screen('Flip', w);
        %         fprintf('flip took %.1f ms\n', (GetSecs-t1)*1000);

        %         fprintf('t1a loop took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;


        tStart=GetSecs;

        while 1
            % We wait at least a few ms each loop-iteration so that we
            % don't overload the system in realtime-priority:
            WaitSecs(0.003);
            % get mouse buttons:
            [mx, my, buttons]=GetMouse;

            [keyIsDown,secs,keyCode] = KbCheck;

            %             if keyIsDown==1
            if keyCode(posKey)==1
                rt=GetSecs-tStart;
                response=posResp;
                break;
            elseif keyCode(negKey)==1
                rt=GetSecs-tStart;
                response=negResp;
                break;
            elseif keyCode(stopKey)==1
                rt=-9999;
                response='stopped';
                stop=1;
                break;
            end
            %             end
            % Break out of loop on mouse click
            if find(buttons)
                stop=1;
                break;
            end
        end
        Screen('FillRect',w, gray);
        Screen('DrawText', w, 'Waiting....', 20, 50, black);
        Screen('Flip', w);

        %         fprintf('t1b loop took %.1f ms\n', (GetSecs-t1)*1000);
        t1=GetSecs;
        fprintf('%s\t%s\t%f\n', imglist(imgnr).name, response, rt);

        % some book keeping and cleaning
        imglist(imgnr).shown=1;
        imglist(imgnr).present=imglist(imgnr).present-1;
        Screen('Close', imgtex); % release memory used by texture
        WaitSecs(0.030);
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


function imglist=getImageListFromDir(imgdir, present, ext)

if ~exist('present', 'var') | ~isempty(present)
    present=1;
end

if ~exist('ext', 'var') | ~isempty(ext)
    ext='.jpg';
end

id=dir(imgdir);
j=1;
for i=1:length(id)
    if id(i).isdir==0 & strcmp(id(i).name(end-3:end), ext)==1
        imglist(j).name=[imgdir filesep id(i).name ];
        fprintf('image #%d ''%s''\n', j, imglist(j).name);
        imglist(j).present=present;
        imglist(j).shown=0;
        j=j+1;
    end
end


function imgtex=imageToTex(imgfile, window, mask)

if ~exist('window', 'var') | isempty(window)
    error('need a correct window argument');
end

% fprintf('imageToTex: Using image ''%s''\n', imgfile);
imdata=imread(imgfile, 'jpg');

size(imdata);
% we add a transparancy layer to each of the images.
if exist('mask', 'var') & ~isempty(mask)
    imdata(:,:,2)=mask; % only correct for gray level images!
end
imgtex=Screen('MakeTexture', window, imdata);




function t=waitForKeyBoardRelease
% wait until keyboard is released
t1=GetSecs;
keyIsDown=1;
while keyIsDown
    [keyIsDown,secs,keyCode] = KbCheck;
    WaitSecs(.01); % leaving this out causes odd timing behaviour!
    keyIsDown;
end
t=GetSecs-t1;
