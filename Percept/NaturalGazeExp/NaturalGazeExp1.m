function TextureGazeExp(subject, session, parfile)
% texture gaze and saliency experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 17-02-07  fwc adapted from TextureGazeExp4

commandwindow;
cd(FunctionFolder(mfilename));

dummymode=1;

% suppress warnings and tests for now. In a real experiment
% you would enable all these again, so to be sure your computer is
% running okay.

oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1);

result=EyelinkInit(dummymode);

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

    %     screenNumber=max(screens);
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=1000; % minimal inter trial interval, in secs
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;
    fixTolerance=4;
    reqFixTime=.5;
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
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tDELAY\tACTSTIMDUR\tTEXTURE\tTARGET\tRESP\tRT\tLAT\n');
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
    %     commandwindow;
    %     showInstr=questdlg('Show Instruction?', 'Instruction')
    %
    HideCursor;

    %     if strcmp(showInstr, 'yes')==1
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


    % this is the start of the trial loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file

    nrTrials=length(par.imageDir); % use length of one of the parameter vectors to determine the number of trials
    trial=1; % initialize trial number
    itiEnd=GetSecs+itiTime/1000*2; % set iti to double duration for the first trial

    while goOn==1 & trial<=nrTrials


        % we'll wait to make sure the subject
        % released any keys, before starting a new trial
        % moreover, we make sure a certain amount of time (itiTime) has
        % passed before starting the new trial by waiting until itiEnd

        while GetSecs<itiEnd | KbCheck
            WaitSecs(0.01);
        end


        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''TRIAL %d''', trial );

        % Always send this message before starting to record.
        % It marks the start of the trial and also
        % contains trial condition data required for analysis.

        Eyelink('message', 'TRIALID %d', trial );
        % do a final check of calibration using driftcorrection
        if 0    EyelinkDoDriftCorrection(el);
        end
        WaitSecs(0.1);
        Eyelink('StartRecording');

        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == el.BINOCULAR; % if both eyes are tracked
            eye_used = el.LEFT_EYE; % use left eye
        end

        % mark start of a new trial by showing the fixation point
        Screen('FillRect', window, gray);
        % seperate function for drawing fixation point, so we can reuse it
        drawFixationPoint(window, fixPtSize, fixPtCol); % show fixation point
        [notUsed delayOnsetTime]=Screen('Flip', window);


        % this function prepares the stimulus
        % it won't show until we issue a flip command
        imageDir=['images' filesep par.imageDir{trial}];

        [imgfile]=createImageStimulus(window, imageDir);

        % add fixationPoint
        %         drawFixationPoint(window, fixPtSize, fixPtCol);

        % drift correction

        % verify fixation stability for a particular amount of time
        Eyelink('message', 'Check Fixation Start' );
        disp('Check Fixation Start');

        [h v]=WindowSize(window);
        fixTolerancePix=round(fixTolerance/100*h);
        [cx, cy]=WindowCenter(window);
        if dummymode==1
            ShowCursor;
            WaitSetMouse(cx+200, cy+200, window);
        end
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

            d=sqrt((mx-cx)^2+(my-cy)^2);
            if d<fixTolerancePix
                if ts<0
                    ts=GetSecs;
                elseif GetSecs-ts>reqFixTime
                    fprintf('fixation point fixated long enough\n');
                    Eyelink('message', 'Check Fixation End' );
                    break;
                end
            else
                ts=-1;
            end

            [keyIsDown,secs,keyCode] = KbCheck;

            % we'll only go into the code below if a key was pressed
            if keyCode(quitKey)
                display('User requested break');
                goOn=0;
                break;
            end
        end

        if goOn==0
            break;
        end
HideCursor;
        [notUsed stimulusOnsetTime]=Screen('Flip', window,[],1);
        Eyelink('message', 'DISPLAY ON');	 % message for RT recording in analysis
        Eyelink('message', 'SYNCTIME');	 	 % zero-plot time for EDFVIEW
        actDelayDur=stimulusOnsetTime-delayOnsetTime;
        tStimEnd=stimulusOnsetTime+par.stimDur(trial)/1000;
        actStimDur=-999; % initialize for later storage of actual stimulus duration
        target=-1;
        response='no';
        rt=-999;
        latency=-999;

        while 1

            % check if we need to remove the stimulus
            if 1 && GetSecs>tStimEnd && actStimDur<0
                % time passed, show next frame!
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
                % otherwise test if one of the specified response keys was pressed
                %                 if keyCode(leftwardKey)==1
                %                     response='left'; % record response
                %                     rt=secs-stimulusOnsetTime; % determine reaction time
                %                     break;
                %                 elseif keyCode(rightwardKey)==1
                %                     response='right';
                %                     rt=secs-stimulusOnsetTime;
                %                     break;
                %                 end
            end

            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % shorter for more frequent sampling of keys
            WaitSecs(0.001);
        end


        %         Eyelink('message', 'TARGET %d', target );
        if 0   Eyelink('message', 'RESPONSE %s', response ); end
        WaitSecs(0.1);
        Eyelink('StopRecording');

        % set the end of the inter trial interval
        itiEnd=GetSecs+itiTime/1000;

        % erase screen after response
        % if response is very fast, the stimulus has not been erased yet.
        Screen('FillRect' ,window, gray);
        drawFixationPoint(window, fixPtSize, fixPtCol); % we grow fix point to show response was recorded
        [notUsed stimulusOffsetTime]=Screen('Flip', window);
        % if actual stimulus duration was not yet calculated, we do this
        % here.
        if actStimDur<0
            actStimDur=stimulusOffsetTime-stimulusOnsetTime;
        end

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
            fprintf(fp, '%s\t%d\t%s\t%.1f\t%.1f\n', imgfile, target, response, rt*1000, latency);
            fclose(fp);
            
        end
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

    Eyelink('ShutDown');


    % stop eyelink
    Eyelink('ShutDown');


    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    diary off

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
catch

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


function [myimgfile]=createImageStimulus(window, imageDir )

white=WhiteIndex(window);
black=BlackIndex(window);
gray=GrayIndex(window);

% get listing of images in directory
dirList=dir(imageDir);
% select valid image/texture files
stimuli=zeros(1,length(dirList));

for i=1:length(dirList)
    if dirList(i).isdir==0 & strcmp(dirList(i).name(end-3:end), '.jpg')==1
        stimuli(i)=1;
    end
end
stimuli=find(stimuli>0);

% randomly pick a stimulus
stimuli=stimuli(randperm(length(stimuli))); % prevents each texture from appearing more than once
stimulus=stimuli(1);

% create texture of image
myimgfile=fullfile(imageDir,dirList(stimulus).name);
%     fprintf('Loading image ''%s''\n', myimgfile{j});
imdata=imread(myimgfile);
tex=Screen('MakeTexture', window, imdata);

Screen('DrawTexture', window, tex);





