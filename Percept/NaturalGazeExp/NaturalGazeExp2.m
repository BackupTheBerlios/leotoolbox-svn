function NaturalGazeExp(subject, session, parfile)
% natural gaze and saliency experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 17-02-07  fwc adapted from TextureGazeExp4
% 19-02-07  fwc now creates list of images based on directories in the par
%               file. Allows to show rotated images. Set linear gamma.

commandwindow;
cd(FunctionFolder(mfilename));

dummymode=1;

% suppress warnings and tests for now. In a real experiment
% you would enable all these again, so to be sure your computer is
% running okay.

oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1);

diary([mfilename 'Log.txt']);

if ~exist('subject', 'var') || isempty(subject)
    subject=input('Subject name (''name'')? ');
    if isempty(subject)
        disp('Experiment stopped');
        diary off;
        return;
    end
end

if ~exist('session', 'var') || isempty(session)
    session=input('Session nr (number)? ');
    if isempty(session)
        disp('No session nr given, experiment stopped');
        diary off;
        return;
    end
end
if ~isnumeric(session)
    disp('Session should be a number, experiment stopped');
    diary off;
    return
end

if ~exist('parfile', 'var') | isempty(parfile)
    parfile=input('Parameter file (''filename'')? ');
    if isempty(parfile)
        disp('No parameter file given, experiment stopped');
        diary off;
        return;
    end
end

try

    result=EyelinkInit(dummymode);


    % here we read in information from the parameter file
    % using the autotextread function. It returns all information
    % in a structure that we call 'par'. The parameters themselves
    % are in fields (e.g. par.stimTime) called after whatever you named them in your
    % parameter file. If we get an error, we quit the experiment

    myparfiledir='parfiles';
    myparfile=[myparfiledir filesep parfile '.txt'] % construct parfile name
    par=autotextread(myparfile)

    % construct edf file name
    sstr=sprintf('%s', num2str(session));
    nl=8-length(sstr);  % edf file name limited to 8 chars
    if length(subject)>nl
        subjstr=subject(1:nl);
    else
        subjstr=subject;
    end
    edfFile=[ subjstr sstr '.edf'];



    % find out about the screens attached to the computer. We take the
    % highest indexed screen as our default. We also get some default
    % colour values.
    screens=Screen('Screens');
    screenNumber=max(screens);
    [h v]=WindowSize(screenNumber);
    mss=1024*768; % hardcoded threshold
    for i=1:length(screens)  % but use bigger screen if there is one ;-)
        [h v]=WindowSize(screens(i));
        if h*v>mss
            mss=h*v;
            screenNumber=screens(i);
        end
    end

    % set linear gamma!!
    newGammaTable=repmat((linspace(0,1024,256)/1024)',1,3);
    oldGammaTable=Screen('LoadNormalizedGammaTable', screenNumber, newGammaTable);
    %     size(oldGammaTable);

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=100; % minimal inter trial interval, in msecs
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;
    saccThreshold=3; % threshold for reaching saccade target
    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.leftwardKey='LeftArrow';
    keyNames.rightwardKey='RightArrow';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    leftwardKey=KbName(keyNames.leftwardKey);
    rightwardKey=KbName(keyNames.rightwardKey);

    % here, we specify the filename of the output file, and we print the header
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!
    mydatadir='data';
    myfile=[mydatadir filesep subject '_' num2str(session) '_' parfile '_' mfilename '_data' '.txt']; % create a meaningful name

    fp=fopen(myfile, 'w'); % 'w' for write which creates a new file always, alternative would be 'a' for append.
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tDELAY\tACTSTIMDUR\tTEXTURE\tLAT\n');
    fclose(fp);


    % here we open a window and paint it gray
    [window, winrect]=Screen('OpenWindow',screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',window, gray);
    Screen('Flip', window);
    monitorRefreshInterval =Screen('GetFlipInterval', window);
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
        frameRate=60; % good assumption for most labtopss/LCD screens
    end



    % this function shows an instruction on the screen for the subject
    % instruction is defined in this function
    HideCursor;
    if 0
        goOn=showInstruction(window, keyNames);
    else
        goOn=1;
    end




    % do eyelink stuff
    el=EyelinkInitDefaults(window);

    el.backgroundcolour = gray;
    el.foregroundcolour = white;
    el.mousetriggersdriftcorr=1; % 1=allow mouse to trigger drift correction
    if dummymode==0
        % make sure that we get gaze data from the Eyelink
        Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA');
        Eyelink('command', 'file_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
        Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
        Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE');

        % open file to record data to
        Eyelink('openfile', edfFile);

        % STEP 4
        % Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);

    end



        %    we  setup a complete  list of valid image files drawn from all dirs
    fim=0;
    for k=1:length(par.imageDir)
        
        imageDir=['images' filesep par.imageDir{k}];
        dirList=dir(imageDir);
        % select valid image/texture files
        stimuli=zeros(1,length(dirList));
        for i=1:length(dirList)
            if dirList(i).isdir==0 && strcmp(dirList(i).name(end-3:end), '.jpg')==1
                stimuli(i)=1;
            end
        end
        stimuli=find(stimuli>0);
        for j=1:length(stimuli)
            imglist.file{fim+j}=fullfile(imageDir,dirList(stimuli(j)).name);
            imglist.row(fim+j)=k;
        end
        fim=length(imglist.file);   % final image
    end

        % randomize stimulus order
        stimuli=randperm(length(imglist.file)); % prevents each texture from appearing more than once
        nrTrials=length(stimuli);

            % this is the start of the experimental loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file

        
        trial=1; % initialize trial number
        itiEnd=GetSecs+itiTime/1000*2; % set iti to double duration for the first trial

        while goOn==1 && trial<=nrTrials

            % this function prepares the stimulus
            % we first create texture of image, for later (fast) drawing

            myimgfile=imglist.file{stimuli(trial)};
            imdata=imread(myimgfile);
            tex=Screen('MakeTexture', window, imdata);
            texRect=Screen('Rect', tex);

            fprintf('Trial: %d, image ''%s'', orientation: %d\n', trial, myimgfile, par.stimOrient(imglist.row(stimuli(trial))));
            
            % we make sure a certain amount of time (itiTime) has
            % passed before starting the new trial by waiting until itiEnd

            while GetSecs<itiEnd || KbCheck
                WaitSecs(0.01);
            end

            % This supplies a title at the bottom of the eyetracker display
            Eyelink('command', 'record_status_message ''TRIAL %d''', trial );

            % Always send this message before starting to record.
            % It marks the start of the trial and also
            % contains trial condition data required for analysis.

            Eyelink('message', 'TRIALID %d', trial );
            Eyelink('message', 'IMAGE %s', myimgfile );

            % do a final check of calibration using driftcorrection
            EyelinkDoDriftCorrection(el);

            % we'll wait to make sure the subject
            % released any keys, before starting the trial
            while KbCheck
                WaitSecs(0.01);
            end
            Eyelink('StartRecording');
            WaitSecs(0.1);

            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if eye_used == el.BINOCULAR; % if both eyes are tracked
                eye_used = el.LEFT_EYE; % use left eye
            end

            % mark start of a new trial by showing a saccade target at a random point
            Screen('FillRect', window, gray);
            [dx dy]=drawSaccadeTarget(window, smallerRect(texRect, winrect), fixPtSize*2, fixPtCol);           
            [cx, cy]=WindowCenter(window);
            if dummymode==1
                ShowCursor;
                WaitSetMouse(cx, cy, window);
            end
            
            [notUsed saccTargetOnsetTime]=Screen('Flip', window);
            Eyelink('message', 'SACCADE TARGET ON AT %d %d', dx, dy);	 % message for RT recording in analysis

            % draw stimulus, it won't be visible until we issue a flip command
            Screen('DrawTexture', window, tex,[],CenterRect(smallerRect(texRect, winrect), winrect), par.stimOrient(imglist.row(stimuli(trial))));

            % check whether a saccade is made to target
            Eyelink('message', 'Check Saccade Start' );
%             disp('Check Saccade Start');

            [h v]=WindowSize(window);
            saccThresholdPix=round(saccThreshold/100*h);
            ts=-1;
            goOn=1;
            while goOn==1
                if dummymode==0
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
                            if x~=el.MISSING_DATA & y~=el.MISSING_DATA & evt.pa(eye_used+1)>0
                                mx=x;
                                my=y;
                            end
                        end
                    end
                else
                    % Query current mouse cursor position (our "pseudo-eyetracker") -
                    % (mx,my) is our gaze position.
                    [mx, my, buttons]=GetMouse(window);
                end

                d=sqrt((mx-dx)^2+(my-dy)^2);
                if d<saccThresholdPix
                    Eyelink('message', 'SACCADE TARGET HIT');	 % message for RT recording in analysis
%                     disp('Check Saccade End');
                    latency=GetSecs-saccTargetOnsetTime; % this latency includes saccade duration itself
                    break;
                end

                [keyIsDown,secs,keyCode] = KbCheck;
                if keyCode(quitKey)
                    display('User requested break');
                    goOn=0;
                    break;
                end
            end

            if goOn==0
                break;
            end

            if dummymode==1
                HideCursor;;
            end
            
            [notUsed stimulusOnsetTime]=Screen('Flip', window,[],1);
            Eyelink('message', 'DISPLAY ON');	 % message for RT recording in analysis
            Eyelink('message', 'SYNCTIME');	 	 % zero-plot time for EDFVIEW
            actDelayDur=stimulusOnsetTime-saccTargetOnsetTime;
            tStimEnd=stimulusOnsetTime+par.stimDur(imglist.row(stimuli(trial)))/1000;
            actStimDur=-999; % initialize for later storage of actual stimulus duration
            target=-1;
            response='no';
            rt=-999;

            while 1
                % check if we need to remove the stimulus
                if GetSecs>tStimEnd-monitorRefreshInterval && actStimDur<0
                    % time passed, erase screen
                    Screen('FillRect', window, gray);
                    drawFixationPoint(window, fixPtSize, fixPtCol);
                    [notUsed stimulusOffsetTime]=Screen('Flip', window, tStimEnd);
                    actStimDur=stimulusOffsetTime-stimulusOnsetTime;
                    Eyelink('message', 'DISPLAY OFF');
                    break;
                end

                % check state of keyboard
                [keyIsDown,secs,keyCode] = KbCheck;

                % we'll only go into the code below if a key was pressed
                if keyIsDown==1
                    % test if the user wanted to stop the program
                    if keyCode(quitKey)
                        display('User requested break');
                        goOn=0;
                        break;
                    end
                end

                % return control to the OS for a short time, to keep it happy.
                % we may loose real-time priority if we do not. Make this time
                % shorter for more frequent sampling of keys
                WaitSecs(0.001);
                Screen('Close'); % close texture
            end


            WaitSecs(0.1);
            Eyelink('StopRecording');

            % set the end of the inter trial interval
            itiEnd=GetSecs+itiTime/1000;

            Screen('Close'); % this will close all textures used

            % if we got an actual response, we now will save the data to a file
            % note that we now append ('a') to the file! We'll multiply the rt
            % and dl parameters by 1000 to get milliseconds. We immediately close the file
            % again (just in case). Note the different symbols used to print
            % out different types of parameters. %s for strings/letters, %d for
            % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
            if goOn==1
                fp=fopen(myfile, 'a'); % open with 'a' for appending info to existing file.
                time=datestr(now, 'HHMMSS'); %  record timestamp of response

                % we distribute printing over a number of  commands for
                % readability
                fprintf(fp, '%s\t%d\t%d\t%s\t%s\t', subject, session, trial, date, time);
                fprintf(fp, '%.1f\t%.1f\t', actDelayDur*1000, actStimDur*1000);
                fprintf(fp, '%s\t%.1f\n', myimgfile, latency*1000);
                fclose(fp);

            end

            Eyelink('message', 'TRIAL END');
            
            % increase the trial number
            trial=trial+1;
        end

    % display a message indicating that the experiment has finished
    if goOn==1
        disp('The experiment has been completed, thanks for participating!');
    else
        % in case of a break, some other message might be more appropriate
        disp('Please contact the experiment leader immediately, thanks!');
    end

    Eyelink('CloseFile');
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end

    % stop eyelink
    Eyelink('ShutDown');
    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);
    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    diary off

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
catch

    Eyelink('ShutDown');
    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);

    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    psychrethrow(psychlasterror);
    diary off
end


function goOn=showInstruction(window, keyNames)

% show instruction on screen
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

tstring=['Welcome to this search experiment\n\n'];
tstring=[tstring 'Press the ''' keyNames.leftwardKey ''' for a gap on the left\n'];
tstring=[tstring 'Press the ''' keyNames.rightwardKey ''' for a gap on the right\n\n'];
tstring=[tstring 'Press the ''' keyNames.quitKey ''' key to abort,\n'];
tstring=[tstring 'any other key to continue'];


Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1);


% this is a handy function provided by the PsychToolbox for
% drawing nicely formatted and centered (if required) text.
% see its help for all options
DrawFormattedText(window, tstring, 'center', 'center', WhiteIndex(window));
Screen('Flip', window);

% wait for key release
while KbCheck
    WaitSecs(0.01);
end

quitKey=KbName(keyNames.quitKey);
% wait for key press
while 1
    [keyIsDown,secs,keyCode] = KbCheck;

    % check if a key was pressed
    if keyIsDown==1
        % test if the user wanted to stop
        if keyCode(quitKey)
            display('User requested break');
            goOn=0;
        else
            goOn=1; % continue with experiment
        end
        break;
    end
    WaitSecs(0.01);
end

% erase the instruction screen
gray=GrayIndex(window);
Screen('FillRect', window, gray);
Screen('Flip', window);




function [dx dy]=drawSaccadeTarget(window, imRect, stSize, stCol)
[h v]=WindowSize(window);
stSize=round(stSize/100*h);
[rh rv]=RectSize(imRect);
[x0 y0]=WindowCenter(window);

minDist=rv/4;
maxDist=rv/2*0.9;

dist=minDist+rand*(maxDist-minDist);

a=rand*2*pi;

dx=x0+cos(a)*dist;
dy=y0+sin(a)*dist;

stRect=CenterRectOnPoint([0 0 stSize stSize], dx, dy);

Screen('FillOval', window, stCol, stRect);



function rect=biggerRect(rect1, rect2)

% estimate what's the bigger rect based on surface
[h1 v1]=RectSize(rect1);
[h2 v2]=RectSize(rect2);

if h1*v1>=h2*v2
    rect=rect1;
else
    rect=rect2;
end


function rect=smallerRect(rect1, rect2)

% estimate what's the bigger rect based on surface
[h1 v1]=RectSize(rect1);
[h2 v2]=RectSize(rect2);

if h1*v1<=h2*v2
    rect=rect1;
else
    rect=rect2;
end







