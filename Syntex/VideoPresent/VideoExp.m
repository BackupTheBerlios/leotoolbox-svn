function VideoExp(subject, session, parfile)
% video experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 17-02-07  fwc adapted from TextureGazeExp4
% 19-02-07  fwc now creates list of images based on directories in the par
%               file. Allows to show rotated images. Set linear gamma.
% 01-05-07  fwc fixed half movie size problem

commandwindow;
cd(FunctionFolder(mfilename));

dummymode=1;

movmag=1;
movort=180;
bgGrayLevel = 0.8;

sliderTitles={'angstig','blij','boos','neutraal','verdrietig','verrast','walgend'};
sliderInstr = 'Wat voor gevoel krijg je bij dit filmpje?';

fixPtInBetweenMovies=0; % if 1, and eyetracker in dummymode, shows a fix point in between movies, and wait for subject response
% Playbackrate defaults to 1:
rate=1;

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

if ~exist('parfile', 'var') || isempty(parfile)
    parfile=input('Parameter file (''filename'')? ');
    if isempty(parfile)
        disp('No parameter file given, experiment stopped');
        diary off;
        return;
    end
end

try

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
    myparfile=[myparfiledir filesep parfile '.txt']; % construct parfile name
    par=autotextread(myparfile);

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

    % set linear gamma!!
    newGammaTable=repmat((linspace(0,1024,256)/1024)',1,3);
    oldGammaTable=Screen('LoadNormalizedGammaTable', screenNumber, newGammaTable);
    %     size(oldGammaTable);

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);
    bgGray=GrayIndex(screenNumber, bgGrayLevel);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=100; % minimal inter trial interval, in msecs
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;
    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.nextKey='SPACE';
    keyNames.leftwardKey='LeftArrow';
    keyNames.rightwardKey='RightArrow';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    nextKey=KbName(keyNames.nextKey);
    leftwardKey=KbName(keyNames.leftwardKey);
    rightwardKey=KbName(keyNames.rightwardKey);

    % here, we specify the filename of the output file, and we print the header
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!
    mydatadir='data';
    myfile=[mydatadir filesep subject '_' num2str(session) '_' parfile '_' mfilename '_data' '.txt']; % create a meaningful name

    fp=fopen(myfile, 'w'); % 'w' for write which creates a new file always, alternative would be 'a' for append.
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tINSTRUCTION\tACTMOVDUR\tMOVIE');
    for k=1:length(sliderTitles)
        fprintf(fp, '\tR_%s', sliderTitles{k});
    end
    fprintf(fp, '\n');

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


    nrTrials=length(par.MOVIE);

    % this is the start of the experimental loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file


    % we'll first print some useful, non-trial specific information to the Eyelink file.

    Eyelink('message', 'SUBJECT %s', subject );
    Eyelink('message', 'SESSION %d', session );
    Eyelink('message', 'PARAMETER_FILE %d', myparfile );
    Eyelink('message', 'DATA_FILE %d', myfile );
    Eyelink('message', 'EDF_FILE %d', edfFile );

    [h v]=WindowSize(window);

    Eyelink('message', 'SCREEN_SIZE_PIX_H %d SCREEN_SIZE_PIX_V %d', h, v);
    Eyelink('message', 'SCREEN_REFRESH_INTERVAL_MS %.1f', monitorRefreshInterval*1000);
    Eyelink('message', 'SCREEN_FRAME_RATE_HZ %.1f', frameRate);

    currInstr='';
    goOn=1;
    trial=1; % initialize trial number
    itiEnd=GetSecs+itiTime/1000*2; % set iti to double duration for the first trial

    while goOn==1 && trial<=nrTrials

        % this function shows an instruction on the screen for the subject

        strcmp(par.INSTRUCTION{trial}, 'No')
        
        if trial==1 || 0==strcmp(par.INSTRUCTION{trial}, 'No')
            currInstr=par.INSTRUCTION{trial};
            goOn=showInstruction(window, currInstr, keyNames);
            if goOn==0
                break;
            end
        end
        % here we prepare the movie stimulus

        moviename=[par.MOVIEDIR{trial} filesep par.MOVIE{trial}];
        
        % Open movie file and retrieve basic info about movie:
        [movie movieduration fps imgw imgh] = Screen('OpenMovie', window, moviename);
        
        fprintf('Trial %d, Movie: %s  w: %d h: %d, Duration: %f secs, %f fps\n', trial, moviename, imgw, imgh, movieduration, fps);

        % Seek to start of movie (timeindex 0):
        Screen('SetMovieTimeIndex', movie, 0);


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
        Eyelink('message', 'MOVIE %s', moviename );


        % do a final check of calibration using driftcorrection
        if dummymode==0
            EyelinkDoDriftCorrection(el);
        elseif fixPtInBetweenMovies==1 % show a fix point in between movies, and wait for subject response
            drawFixationPoint(window, fixPtSize, fixPtCol);
            vbl=Screen('Flip', window);
            keyIsDown=0;
            buttons=0;
            while keyIsDown==0 && ~any(buttons)
                [keyIsDown,secs,keyCode] = KbCheck;
                [mx, my, buttons]=GetMouse(window);
                WaitSecs(0.01);
            end

        end

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

        % Start playback of movie. This will start
        % the realtime playback clock and playback of audio tracks, if any.
        % Play 'movie', at a playbackrate = 1, with endless loop=1 and
        % 1.0 == 100% audio volume.
        Screen('PlayMovie', movie, rate, 0, 1.0);

        actStimDur=-999; % initialize for later storage of actual stimulus duration
        first=1;
        i=0;
        t1 = GetSecs;
        stimulusOnsetTime=-1;
        movieDone=0;
        pts=0;
        movieEnd=Getsecs+movieduration;
        % Infinite playback loop: Fetch video frames and display them...
        while movieDone==0 && Getsecs<=movieEnd && movieduration-pts>=0.01
            i=i+1;
            if (abs(rate)>0)
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex either the texture handle or zero if no new frame is
                % ready yet. pts = Presentation timestamp in seconds.
                [tex pts] = Screen('GetMovieImage', window, movie, 1);

                % Valid texture returned?
                if tex<0
                    movieDone=1;
                    break;
                end;
                
%                 myrect=Screen('Rect', tex);
%                 [tw th]=RectSize(myrect)
                % Draw the new texture immediately to screen:
                Screen('FillRect', window, bgGray);
                Screen('DrawTexture', window, tex, [], CenterRect([0 0 movmag*imgw movmag*imgh], winrect ), movort);

                % Update display:
                vbl=Screen('Flip', window);
                if first==1
                    stimulusOnsetTime=vbl;
                    Eyelink('message', 'MOVIE ON');	 % message for RT recording in analysis
                    Eyelink('message', 'SYNCTIME');	 	 % zero-plot time for EDFVIEW
                    first=0;
                end
                % Release texture:
                Screen('Close', tex);
            end


            % check state of keyboard
            [keyIsDown,secs,keyCode] = KbCheck;
            [mx, my, buttons]=GetMouse(window);
            % we'll only go into the code below if a key was pressed
            if keyIsDown==1
                % test if the user wanted to stop the program
                if keyCode(quitKey) || any(buttons)
                    display('User requested break');
                    goOn=0;
                    break;
                end

                if keyCode(nextKey)
                    display('stop movie');
                    break;
                end

            end

            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % 
            % shorter for more frequent sampling of keys
            WaitSecs(0.001);

        end

        % Done. Stop playback:
        droppedcount = Screen('PlayMovie', movie, 0, 0, 0);        

%         Screen('PlayMovie', movie, 0);
        Screen('FillRect', window, gray);
        %         drawFixationPoint(window, fixPtSize, fixPtCol);
        stimulusOffsetTime=Screen('Flip', window);
        actStimDur=stimulusOffsetTime-stimulusOnsetTime
        Eyelink('message', 'DISPLAY OFF');

        % Close movie object:
        Screen('CloseMovie', movie);


        WaitSecs(0.1);
        Eyelink('StopRecording');

        % set the end of the inter trial interval
        itiEnd=GetSecs+itiTime/1000;

        Screen('Close'); % this will close any textures used


        % get response from subject

        [rating, rt, stop] = mult_SliderResponse(window,sliderTitles,sliderInstr);
        Screen('FillRect', window, gray);
        vbl=Screen('Flip', window);

        if stop==1
            goOn=0;
        end

        % if we got an actual response, we now will save the data to a file
        % note that we now append ('a') to the file! We'll multiply the rt
        % and dl parameters by 1000 to get milliseconds. We immediately close the file
        % again (just in case). Note the different symbols used to print
        % out different types of parameters. %s for strings/letters, %d for
        % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
        if goOn==1
            fp=fopen(myfile, 'a'); % open with 'a' for appending info to existing file.
            time=datestr(now, 'HH-MM-SS'); %  record timestamp of response

            % we distribute printing over a number of  commands for
            % readability
            fprintf(fp, '%s\t%d\t%d\t%s\t%s\t', subject, session, trial, date, time);
            fprintf(fp, '%s\t%.1f\t', currInstr, actStimDur);
            fprintf(fp, '%s', moviename);
            for k=1:length(rating)
                fprintf(fp, '\t%.1f', rating(k));
            end
            fprintf(fp, '\n');

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


function goOn=showInstruction(window, instr, keyNames)

% show instruction on screen
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

tstring=['Welkom bij dit experiment\n\n'];
tstring=[tstring 'Instructie:\n\n'];

tstring=[tstring instr '\n\n\n\n'];
tstring=[tstring 'Press the ''' keyNames.nextKey ''' key to quickly advance to the next movie,\n'];
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







