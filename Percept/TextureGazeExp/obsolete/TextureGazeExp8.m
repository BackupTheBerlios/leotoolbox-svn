function TextureGazeExp(subject, session, parfile)
% texture gaze and saliency experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 18-01-07  fwc created
% 17-02-2007    FWC circularly defined gaussian mask, sharper edges too
% 18-02-2007    fwc driftcorrection added.

% to do
%   complete logging (stim size)
%   make flexible for different texture sizes (add cropping?)
%   test on a really big screen

commandwindow;
cd(FunctionFolder(mfilename));

dummymode=1;

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

% try
    % open connection to eye tracker

    [result dummymode]=EyelinkInit(dummymode);
    if result==0
        if dummymode==1
            disp('Could not dummy-initialize eye tracker, experiment stopped');
        else
            disp('Could not initialize eye-tracker, experiment stopped');
        end
        return;
    end

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
    sstr=[sstr parfile(1:(min(2,length(parfile))))];
    nl=8-length(sstr);  % edf file name limited to 8 chars
    if length(subject)>nl
        subjstr=subject(1:nl);
    else
        subjstr=subject;
    end
    edfFile=[ subjstr sstr '.edf'];

disp(edfFile);

    % suppress warnings and tests for now. In a real experiment
    % you would enable all these again, so to be sure your computer is
    % running okay.

    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests', 1);

    % find out about the screens attached to the computer. We take the
    % highest indexed screen as our default. We also get some default
    % colour values.
    screens=Screen('Screens');
    screenNumber=max(screens);
    [h v]=WindowSize(screenNumber);
    mss=1024*768; % hardcoded threshold
    for i=1:length(screens)  % but use bigger screen if there is one ;-)
        [h v]=WindowSize(screens(i));
        if h*v>=mss
            mss=h*v;
            screenNumber=screens(i);
        end
    end
    % set linear gamma!!
    newGammaTable=repmat((linspace(0,1024,256)/1024)',1,3);
    oldGammaTable=Screen('LoadNormalizedGammaTable', screenNumber, newGammaTable);
    %     size(oldGammaTable);

    %     screenNumber=max(screens);
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=500; % minimal inter trial interval, in secs
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;
    fixTolerance=4;
    reqFixTime=.5;
    maxFCDur=5; %maximum time to check fixation accuracy, after that, we'll enforce a driftcorrection
    enforceDriftCorr=10; % amount of trials after which we enforce a driftcorrection
    stimDurAfterSaccOnset=.25;
    mouseDispl=10; % displacement of mouse in dummymode, percentage of screen
    gapTime=0.2; % time prior to stimulus display, during which there is no fixation point

    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.leftwardKey='LeftArrow';
    keyNames.rightwardKey='RightArrow';

    keyNames.pauseKey{1}='LeftControl';
    %     keyNames.pauseKey{1}='space';
    keyNames.pauseKey{2}='LeftAlt';
    keyNames.pauseKey{3}='LeftGUI';

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
    fprintf(fp, 'SUBJECT\tSESSION\tROW\tTRIAL\tDATE\tTIME\tDELAY\tGAP\tACTSTIMDUR\tTTEXTURE\tTTEXTANGLE\tTPOS\tCTEXTURE\tCTEXTANGLE\tCHOICE\tRESPONSE\tLAT\n');
    fclose(fp);


    % here we open a window and paint it gray
    [window, winrect]=Screen('OpenWindow',screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',window, gray);
    Screen('Flip', window);
    monitorRefreshInterval =Screen('GetFlipInterval', window);
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
        frameRate=60; % good assumption for most labtops/LCD screens
    end

    % report some screen settings in results file
    myresfile=[mydatadir filesep subject '_' num2str(session) '_' parfile '_' mfilename '_results' '.txt']; % create a meaningful name
    fp=fopen(myresfile, 'w'); % open with 'a' for appending info to existing file.

    [w h]=WindowSize(window);
    fprintf(fp, 'EXPERIMENTCODEFILE\t%s\n', mfilename);
    fprintf(fp, 'PARAMETERFILE\t%s\n', myparfile);
    fprintf(fp, 'DATAFILE\t%s\n', myfile);
    fprintf(fp, 'RESULTSFILE\t%s\n', myresfile);
    fprintf(fp, 'EDFFILE\t%s\n', edfFile);
    fprintf(fp, 'SCREENSIZEPIX\t%d\t%d\n', w, h);
    fprintf(fp, 'SCREENREFRESH\t%f\n', frameRate);
    fprintf(fp, 'RESPONSEKEYS\t%s\t%s\n', keyNames.leftwardKey, keyNames.rightwardKey);

    fprintf(fp, 'SUBJECT\t%s\n', subject);
    fprintf(fp, 'SESSION\t%d\n', session);
    fprintf(fp, 'DATE\t%s\n', date);

    fclose(fp);



    % this function shows an instruction on the screen for the subject
    % instruction is defined in this function
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
    
    [oswin, osrect]=Screen('OpenOffscreenWindow', window, gray);
    
    row=1;

    nrTrials=par.nTrials(row); % use value in first line to determine the number of trials
    trial=1; % initialize trial number
    itiEnd=GetSecs+itiTime/1000*2; % set iti to double duration for the first trial

    disp('start trial loop');

    while goOn==1 && trial<=nrTrials

        % check if the subject wants to pause
        [goOn paused]=checkForPause(window, keyNames, nrTrials-trial+1);
        if goOn==0
            break;
        end
        while KbCheck
            WaitSecs(0.01);
        end



        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''TRIAL %d''', trial );

        % Always send this message before starting to record.
        % It marks the start of the trial and also
        % contains trial condition data required for analysis.

        Eyelink('message', 'TRIALID %d', trial );

        %  enfore drift correction every X trials or after pause

        if dummymode==0 && (mod(trial, enforceDriftCorr)==0 || paused==1)
            Eyelink('message', 'Enforcing driftcorrection after %d trials', enforceDriftCorr );
            EyelinkDoDriftCorrection(el);
        end

        Eyelink('StartRecording');
        WaitSecs(0.1);

        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == el.BINOCULAR; % if both eyes are tracked
            eye_used = el.LEFT_EYE; % use left eye
        end

        % mark start of a new trial by showing the fixation point
        Screen('FillRect', window, gray);
        % seperate function for drawing fixation point, so we can reuse it
        drawFixationPoint(window, fixPtSize, fixPtCol); % show fixation point
        [notUsed delayOnsetTime]=Screen('Flip', window);

        % prepare stimulus , in a seperate function
        % most of the information for creating the stimulus comes from
        % the parameter file/par structure.
        % and wait until end of the stimulus onset asynchrony time to
        % display stimulus on screen, screen's flip command also returns the
        % stimulus onset time

        % this function prepares the stimulus
        % it won't show until we issue a flip command
%         imageDir=['images' filesep par.imageDir{row}];

        targetDir=['images' filesep par.imageDir{row} filesep par.targetDir{row}];
        distrDir=['images' filesep par.imageDir{row} filesep par.distrDir{row}];


        % %         [imgfiles, nStim, xpos, ypos, gapangle,
        % texAngle]=createImageStimulus(window, imageDir, par.nrStimuli(trial), par.stimRadius(trial), par.stimSize(trial), par.stimOrient(trial), par.maskSD(trial));
%         window
        [oswin2, imgfiles, tpos, nStim, xpos, ypos, gapangle, texAngle]=createImageStimulus(window, oswin, targetDir, distrDir, par.nrStimuli(row), par.stimRadius(row), par.stimSize(row), par.stimOrient(row), par.maskSD(row));
        % add fixationPoint
        %drawFixationPoint(window, fixPtSize, fixPtCol);

        % we'll wait to make sure the subject
        % released any keys, before starting a new trial
        % moreover, we make sure a certain amount of time (itiTime) has
        % passed before starting the new trial by waiting until itiEnd

        while GetSecs<itiEnd % || KbCheck
            WaitSecs(0.01);
        end

        % verify fixation stability for a particular amount of time
        Eyelink('message', 'Check Fixation Start' );
        disp('Check Fixation Start');

        [h v]=WindowSize(window);
        fixTolerancePix=round(fixTolerance/100*h);
        movThresholdPix=round((par.stimRadius(row)/100)*h/2);
        [cx, cy]=WindowCenter(window);
        if dummymode==1
            ShowCursor;
            md=round(mouseDispl/100*h);
            WaitSetMouse(cx+md, cy+md, window);
        end
        ts=-1;
        goOn=1;
        tfcEnd=GetSecs+maxFCDur; %max time fixation check may take before we enforce driftcorrection
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

            if dummymode==0 && GetSecs > tfcEnd
                Eyelink('message', 'Enforcing driftcorrection: no accurate fixation after %d ms', round(maxFCDur*1000) );
                EyelinkDoDriftCorrection(el);
            end

            [keyIsDown,secs,keyCode] = KbCheck;

            % we'll only go into the code below if a key was pressed
            if keyCode(quitKey)
                display('User requested break');
                goOn=0;
                break;
            end
        end
        %         HideCursor;

        if goOn==0
            break;
        end

        Screen('FillRect', window, gray);
        [notUsed gapOnsetTime]=Screen('Flip', window,[],1);
        Eyelink('message', 'GAP ON');	 % message for analysis

        reqStimulusOnsetTime=gapOnsetTime+gapTime;
        
        Screen('CopyWindow', oswin, window);
        
        [notUsed stimulusOnsetTime]=Screen('Flip', window,reqStimulusOnsetTime,1);
        Eyelink('message', 'DISPLAY ON');	 % message for RT recording in analysis
        Eyelink('message', 'SYNCTIME');	 	 % zero-plot time for EDFVIEW
        actGapDur=stimulusOnsetTime-delayOnsetTime;
        actDelayDur=stimulusOnsetTime-gapOnsetTime;
        tStimEnd=stimulusOnsetTime+par.stimDur(row)/1000;
        actStimDur=-999; % initialize for later storage of actual stimulus duration
        choice=-1;
        response=-98765;
        rt=-999;
        [mx, my, buttons]=GetMouse(window);
        %         pause
        % this is the start of the response loop

        while 1

            % check if we need to remove the stimulus
            if 0 && GetSecs>tStimEnd && actStimDur<0
                % time passed, show next frame!
                Screen('FillRect', window, gray);
                drawFixationPoint(window, fixPtSize, fixPtCol);

                [notUsed stimulusOffsetTime]=Screen('Flip', window, tStimEnd);
                actStimDur=stimulusOffsetTime-stimulusOnsetTime;
            end

            % check whether the subject made an eye-movement to one of the
            % targets

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

            % find distance to objects, pick minimum one
            if d>movThresholdPix
                if choice<0
                    imdist=sqrt((xpos-mx).^2+(ypos-my).^2);
                    choice=find(imdist==min(imdist));
                    latency=GetSecs-stimulusOnsetTime;
                    Screen('FillOval', window, [255 0 0], CenterRectOnPoint([0 0 30 30], xpos(choice), ypos(choice)));
                    Screen('Flip', window, [],1);
                end
            end

            if choice>0
                break;
            end

            % check state of keyboard
            [keyIsDown,secs,keyCode] = KbCheck;

            % we'll only go into the code below if a key was pressed
            if keyIsDown==1 || any(buttons)
                % test if the user wanted to stop the program
                if keyCode(quitKey)
                    display('User requested break');
                    Eyelink('message', 'User requested break');
                    response=-9999;
                    rt=-999;
                    goOn=0;
                    break;
                end
                %                 % otherwise test if one of the specified response keys was pressed
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

        if goOn==1 % valid trial
            % wait short time to give subject time to recognize target
            WaitSecs(stimDurAfterSaccOnset);
        end


        %         Eyelink('message', 'TARGET %d', choice );
        Eyelink('message', 'CHOICE %d', choice );
        Eyelink('message', 'TARGET_ORIENTATION %.1f', texAngle(choice) );
        Eyelink('message', 'LATENCY_MS %.1', latency*1000 );

        Eyelink('message', 'RESPONSE %d', tpos==choice );
        Eyelink('StopRecording');

        % set the end of the inter trial interval
        itiEnd=GetSecs+itiTime/1000;

        % erase screen after response
        % if response is very fast, the stimulus has not been erased yet.
        Screen('FillRect',window, gray);
        %         drawFixationPoint(window, fixPtSize*2, fixPtCol); % we grow fix point to show response was recorded
        [notUsed stimulusOffsetTime]=Screen('Flip', window);
        % if actual stimulus duration was not yet calculated, we do this
        % here.
        if actStimDur<0
            actStimDur=stimulusOffsetTime-stimulusOnsetTime;
        end

%         Screen('Close'); % this will close all textures used


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
            fprintf(fp, '%s\t%d\t%d\t%d\t%s\t%s\t', subject, session, row, trial, date, time);
            fprintf(fp, '%.1f\t%.1f\t%.1f\t', actDelayDur*1000, actGapDur*1000, actStimDur*1000);
            fprintf(fp, '%s\t%.1f\t%d\t', imgfiles{tpos}, texAngle(tpos), tpos);
            fprintf(fp, '%s\t%.1f\t%d\t%.1f\n', imgfiles{choice}, texAngle(choice), choice, tpos==choice, latency*1000);
            fclose(fp);


            % alternate data file
            fp=fopen(myresfile, 'a'); % open with 'a' for appending info to existing file.
            fprintf(fp, 'TRIAL\t%d\n', trial);
            fprintf(fp, 'TIME\t%s\n', time);
            fprintf(fp, 'STIMULUS\n');
            fprintf(fp, 'XPOS\tYPOS\tSIZE\tORIENT\tGAPANGLE\tISTARGET\tIMAGE\n');
            for i=1:length(imgfiles)
                fprintf(fp, '%d\t%d\t%d\t%.1f\t%d\t%d\t%s\n', xpos(i), ypos(i), -999, texAngle(i), gapangle(i), (i==choice), imgfiles{i} );
            end
            fprintf(fp, 'DELAY\t%.f\n', actDelayDur*1000);
            fprintf(fp, 'DELAY\t%.f\n', actGapDur*1000);
            fprintf(fp, 'ACTSTIMDUR\t%.f\n', actStimDur*1000);
            fprintf(fp, 'TARGET_TEXTURE\t%s\n', imgfiles{choice});
            fprintf(fp, 'TARGET_TEXTURE_ANGLE\t%s\n', imgfiles{choice});
            fprintf(fp, 'TARGET_NR\t%d\n', choice);
            fprintf(fp, 'RESPONSE\t%s\n', response);
            %             fprintf(fp, 'RT\t%.1f\n', rt*1000);
            fprintf(fp, 'LATENCY_MS\t%.1f\n', latency*1000);
            fprintf(fp, '--------------\n')

        end
        % increase the trial number
        trial=trial+1


    end

    % display a message indicating that the experiment has finished
    if goOn==1
        disp('The experiment has been completed, thanks for participating!');
    else
        % in case of a break, some other message might be more appropriate
        disp('Please contact the experiment leader immediately, thanks!');
    end

    Eyelink('message', 'EXPERIMENT END');
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
% catch
% 
%     Eyelink('ShutDown');
%     Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);
%     Screen('CloseAll');
%     ShowCursor;
% 
%     % Restore preferences
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);
% 
%     psychrethrow(psychlasterror);
%     diary off
% end




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


function [oswin, myimgfile, tpos, nStim, xpos, ypos, gapangle, texAngle]=createImageStimulus(window, oswin, targetDir, distrDir, nStim, radius, siz, ori, masksd )

white=WhiteIndex(window);
black=BlackIndex(window);
gray=GrayIndex(window);

% get listing of images in distractor directory
dirList=dir(distrDir);
% select valid image/texture files
stimuli=zeros(1,length(dirList));

for i=1:length(dirList)
    if dirList(i).isdir==0 && strcmp(dirList(i).name(end-3:end), '.jpg')==1
        stimuli(i)=1;
    end
end
stimuli=find(stimuli>0);

% randomly pick nStimuli
stimuli=stimuli(randperm(length(stimuli))); % prevents each texture from appearing more than once
distr=stimuli(1:min(nStim,length(stimuli)));


for i=1:length(distr)
%     distr(i)
%     dirList(distr(i)).name
    myimgfile{i}=fullfile(distrDir,dirList(distr(i)).name);
end

% get listing of images in target directory
dirList=dir(targetDir);
% select valid image/texture files
stimuli=zeros(1,length(dirList));

for i=1:length(dirList)
    if dirList(i).isdir==0 && strcmp(dirList(i).name(end-3:end), '.jpg')==1
        stimuli(i)=1;
    end
end
stimuli=find(stimuli>0);

% randomly pick a target
target=stimuli(randperm(length(stimuli))); % prevents each texture from appearing more than once
target=target(1);
tpos=randperm(nStim);
tpos=tpos(1);
myimgfile{tpos}=fullfile(targetDir,dirList(target).name);

% myimgfile
% length(myimgfile)
% create texture of each image
for i=1:length(myimgfile)
    %     myimgfile{j}=fullfile(imageDir,dirList(i).name);
%         fprintf('Loading image ''%s''\n', myimgfile{i});
    imdata=imread(myimgfile{i});

    if ~exist('mask', 'var') || isempty(mask)
%         disp('calculating mask');
        % here, we determine the size of stimulus, and make a fitting mask
        % We create a Luminance+Alpha matrix for use as a transparency mask:
        % for speed, we assume all images are uneven and identical in size!

        msx=(size(imdata,1)-1)/2;
        msy=msx; % should actually be equal by now

        [x,y]=meshgrid(-msx:msx, -msy:msy);
        % ms=100;
        % [x,y]=meshgrid(-ms:ms, -ms:ms);

        % dist from center

        d=sqrt(x.^2+y.^2);
        pp=4; % 4 gives sharper edge
        dm=0; % center
        dsd=msx/1.5; % looks okay, empirically
        mask=uint8(round(exp(-((d-dm)/dsd).^pp)*white));

    end
    % this function is a bit slow on my G4
    % imdata=cropAndAddMask(imdata, 4, 1.5, 0); % power, standard dev, offset from center

    transLayer=size(imdata,3)+1;
    imdata(:,:,transLayer)=mask;
    tex(i)=Screen('MakeTexture', window, imdata);
end

[h v]=WindowSize(window);

radius=radius/100*h;
ang=linspace(0, 360, length(tex)+1);
ang=ang(1:end-1);
[x0 y0]=WindowCenter(window);
xpos=x0+round(radius*cos(deg2rad(ang)));
ypos=y0+round(radius*sin(deg2rad(ang)));

siz=round(siz/100*h);
rect=[0 0 2*siz+1 2*siz+1];
if 0 lct=landoltCTexture(window, 2*siz+1, GrayIndex(window,0.55), gray, 'right'); end
% gapangle=linspace(0,360,length(xpos)+1);
% gapangle=gapangle(1:end-1);
% gapangle=gapangle(randperm(length(gapangle)));

gapangle=1:length(xpos);
gapangle=mod(gapangle,2)*180; % left or right
gapangle=gapangle(randperm(length(gapangle)));

for i=1:length(tex)

    if 0
        dRect=CenterRectOnPoint(rect, xpos(i), ypos(i));
    else
        % use native resolution of texture
        dRect=CenterRectOnPoint(Screen('Rect', tex(i)), xpos(i), ypos(i));
    end


    if 0 Screen('DrawTexture', oswin, lct, [], dRect, gapangle(i)); end

    texAngle(i)=-ori+2*rand*ori;
    % texAngle(i)=0;
%     window
    Screen('DrawTexture', oswin, tex(i), [], dRect, texAngle(i));
%     if i==tpos
%         Screen('FrameRect', window, white, dRect);
%     end
Screen('Close', tex(i));
end
% close textures to free memory
% Screen('Close'); % closes all textures
nStim=length(tex);




function lct=landoltCTexture(window, size, color, background, gap)

rect=[0 0 size size];
lct=Screen('OpenOffscreenWindow', window, background, rect);
[x0 y0]=WindowCenter(lct);
landoltC(lct, x0, y0, size, color, background, gap);



function [goOn paused]=checkForPause(window, keyNames, trialsLeft)

% check if subject needs a break
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

goOn=1;
paused=0;
[keyIsDown,secs,keyCode] = KbCheck;

if 1==keyIsDown
    quitKey=KbName(keyNames.quitKey);

    for i=1:length(keyNames.pauseKey)
        pauseKey(i)=KbName(keyNames.pauseKey{i});
    end

    % we'll only go into the code below if a key was pressed
    if keyCode(quitKey)
        display('User requested break');
        goOn=0;
        return;
    elseif keyCode(pauseKey(1)) && keyCode(pauseKey(2)) && keyCode(pauseKey(3))
        display('User requested pause');
        % wait to make sure the subject released any keys
    else
        return;
    end
else
    return;
end

% we need to show a pause screen
% set up message
tstring=['Pausing experiment\n\n'];
if exist('trialsLeft', 'var') && ~isempty(trialsLeft)
    tstring=[tstring num2str(trialsLeft) ' trials left to do.\n\n'];
end
tstring=[tstring 'Press the ''' keyNames.quitKey ''' key to abort,\n'];
tstring=[tstring 'Press any other key to continue.'];

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

% wait for key press
while 1
    [keyIsDown,secs,keyCode] = KbCheck;

    % check if a key was pressed
    if keyIsDown==1
        % test if the user wanted to stop
        if keyCode(quitKey)
            display('User requested break');
            goOn=0;
        end
        break;
    end
    WaitSecs(0.01);
end

% erase the instruction screen
gray=GrayIndex(window);
Screen('FillRect', window, gray);
Screen('Flip', window);

paused=1;


function imdata=cropAndAddMask(imdata, pp, sd, dm)

persistent mask oldpp oldsd olddm;
% pp= power of gaussian mask
% sd= standard deviation of gaussian mask
% dm= offset of mask (non-zero will result in donut shaped mask

% crop image data so that it becomes square (and uneven in size)

% Crop image if it is even.

[iy, ix, id]=size(imdata);

if mod(ix,2)==0
    dx=1;
else
    dx=0;
end

if mod(iy,2)==0
    dy=1;
else
    dy=0;
end

imdata=imdata(1:iy-dy, 1:ix-dx,:);

% Crop image again if it is non square.

if ix>=iy
    cl=round((ix-iy)/2);
    cr=(ix-iy)-cl;
else
    cl=0;
    cr=0;
end

if iy>=ix
    ct=round((iy-ix)/2);
    cb=(iy-ix)-cl;
else
    ct=0;
    cb=0;
end


imdata=imdata(1+ct:iy-cb, 1+cl:ix-cr,:);
[iy, ix, id]=size(imdata);

%     We create a Luminance+Alpha matrix for use as a transparency mask:

% pp~=oldpp
% sd~=oldsd
% dm~=olddm
% isempty(mask)
% size(mask,1)~=ix
% size(mask,2)~=iy

if isempty(oldpp) || isempty(oldsd) || isempty(olddm) || pp~=oldpp || sd~=oldsd || dm~=olddm || isempty(mask) || size(mask,1)~=ix || size(mask,2)~=iy
    % calculate mask again
    disp('calculating mask');
    msx=(ix-1)/2;
    msy=msx; % should actually be equal by now

    [x,y]=meshgrid(-msx:msx, -msy:msy);

    % calc dist from center

    d=sqrt(x.^2+y.^2); % distance from center of image

    dsd=msx/sd; % sd=1.5 looks okay, at least empirically
    mask=uint8(round(exp(-((d-dm)/dsd).^pp)*255));
end

transLayer=size(imdata,3)+1; % transparency layer differs for b&w and colour images
imdata(:,:,transLayer)=mask;

size(imdata)
% store old mask data
oldpp=pp;
oldsd=sd;
olddm=dm;
