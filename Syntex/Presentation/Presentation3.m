function Presentation(subject, session, parfile)
% stimulus presentation in fmri experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 17-02-07  fwc adapted from TextureGazeExp4
% 19-02-07  fwc now creates list of images based on directories in the par
%               file. Allows to show rotated images. Set linear gamma.
% april 07  fwc adapted to VideoExp, for showing movies and getting them
%               rated. Multi-slider rating function by Richard Jacobs.
% april 07  fwc adapted to Presentation, for showing movies and images in
%               fMRI experiment.
%           fwc add (remote control of) video recording
% 09-05-07 fwc  add (local) video recording



commandwindow;
cd(FunctionFolder(mfilename));

dummymode=1;
TR=2.5;
triggerWaitTime=0.25; % time before end of event that we go prepare next event, and wait for trigger
displayNextEventMessage=0;

instruction = 'kijk naar de filmpjes'; % instruction
logfiledir='logfiles';
fixPtInBetweenStimuli=0; % if 1, and eyetracker in dummymode, shows a fix point in between movies, and wait for subject response
% Playbackrate defaults to 1:
rate=1;
firstTriggerTime=-999999;

% stuff for videorecording
videoRecMode=1; % 0== rec off, 1==rec on, 2= dummymode
recmoviedir='movierecords';
logVideoFrameMode='logFramesOff'; % 'logFramesOff;
movieRecStartTime=0;

% suppress warnings and tests for now. In a real experiment
% you would enable all these again, so to be sure your computer is
% running okay.

oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 1);


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
    makedir(logfiledir);
    diary([logfiledir filesep subject '_session' num2str(session) '_log.txt']);

    % initialize eyetracker here

    % here we read in information from the parameter file
    % using the autotextread function. It returns all information
    % in a structure that we call 'par'. The parameters themselves
    % are in fields (e.g. par.stimTime) called after whatever you named them in your
    % parameter file. If we get an error, we quit the experiment

    myparfiledir='parfiles';
    myparfile=[myparfiledir filesep parfile '.txt']; % construct parfile name
    par=autotextread(myparfile);


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
    keyNames.triggerKey='t';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    triggerKey=KbName(keyNames.triggerKey);
    nextKey=KbName(keyNames.nextKey);
    leftwardKey=KbName(keyNames.leftwardKey);
    rightwardKey=KbName(keyNames.rightwardKey);

    % here, we specify the filename of the output file, and we print the header
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!
    mydatadir='data';
    makedir(mydatadir);
    myfile=[mydatadir filesep subject '_' num2str(session) '_' parfile '_' mfilename '_data' '.txt']; % create a meaningful name

    fp=fopen(myfile, 'w'); % 'w' for write which creates a new file always, alternative would be 'a' for append.
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tINSTRUCTION\tACTSTIMDUR\tMOVIE');
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

    if videoRecMode>0
        % tell recorder where to save movie files
        % we can create a new dir for each subject
        mvdir=[recmoviedir filesep subject]; %
        VideoRecorder('moviedir', mvdir);
        % tell recorder to save to which movie file
        % each session can have its own movie file
        % this will also open log file, so we can write some messages
        moviename=[subject '_' parfile '_session' num2str(session) ]; %
        VideoRecorder('moviename', moviename);

        % initialize video recording here, provide window
        % initiallize dummy if no camera attached
        if videoRecMode==2
            VideoRecorder('initdummy', window);
        else
            VideoRecorder('init', window);
        end
        % log each frame?
        VideoRecorder( logVideoFrameMode );

        VideoRecorder('message', ['Subject: ' subject ] );
        VideoRecorder('message', ['Session: ' num2str(session) ] );
        VideoRecorder('message', ['Par file: ' myparfile ] );
    end


    goOn=showInstruction(window, instruction, keyNames);
    if goOn==0
        display('User requested break');
        sca;
        return
    end

    nrEvents=length(par.EVENTTYPE);

    % this is the start of the experimental loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file

    % set priority to highest possible
    np=MaxPriority(window);
    oldPriority=Priority(np);


    % start video recording
    if videoRecMode>0
        disp('start video recording');
        VideoRecorder('startrecording'); % start grabbing
        movieRecStartTime=GetSecs;
        VideoRecorder('message', ['MovieRecStartTime: ' sprintf('%.2f', movieRecStartTime ) ] );
    end

    % we'll first print some useful, non-trial specific information to the Eyelink file.

    [tt goOn]=WaitForTrigger(triggerKey, quitKey, 0.1); % just so that we have used it
    [mx, my, buttons]=GetMouse(window);

    [h v]=WindowSize(window);

    % dummy play a movie
    % this appears to be necessary to get the first movie (can be
    % different), to start immediately after trigger reception
    % closing this dummymovie takes away this effect.
    
    event=4;
    moviename=[par.STIMDIR{event} filesep par.STIMULUS{event}];

    % Open movie file and retrieve basic info about movie:
    [dummymovie movieduration fps imgw imgh] = Screen('OpenMovie', window, moviename);

    fprintf('Event %d, Movie: %s  , Duration: %f secs, %f fps\n', event, moviename, movieduration, fps);
    % Seek to start of movie (timeindex 0):
    Screen('SetMovieTimeIndex', dummymovie, 0);
    Screen('PlayMovie', dummymovie, 30, 0, 1.0);
    tex=1;
    ts=GetSecs;
    while tex>0
        [tex pts] = Screen('GetMovieImage', window, dummymovie, 1);
        if tex>0
            Screen('Close', tex);
        end
    end
    fprintf('Movie dummy play duration: %f\n', GetSecs-ts);
%     Screen('CloseMovie', dummymovie);
    
    maxWait=6000; % or inf
    currInstr='';
    triggerTime=0;
    goOn=1;
    first=1;
    stimPrepReady=0;
    movieStarted=0;
    stimulusOnsetTime=-1;
    actStimDur=-999; % initialize for later storage of actual stimulus duration
    pts=0;
    stimulusDone=0;
    waitForTrigger=0;

    event=1; % initialize trial number

    while goOn==1 && event<=nrEvents

        %         disp(['Upcoming event: ' par.EVENTTYPE{event}]);
        %         VideoRecorder('message', ['Upcoming event: ' par.EVENTTYPE{event}] );

        % prepare stimulus/instruction depending on the coming event
        while stimPrepReady==0
            %             disp('preploop');
            disp(['Upcoming event: ' par.EVENTTYPE{event}]);
            VideoRecorder('message', ['Upcoming event: ' par.EVENTTYPE{event}] );
            switch( par.EVENTTYPE{event})
                case 'WaitForScanner',
                    % Print a "wait for scanner" message to indicate waiting for scanning onset
                    goOn=WaitForScanner(window, keyNames);
                    VideoRecorder('message', ['Wait for scanner'] );

                    stimPrepReady=0;
                    waitForTrigger=1;
                    firstTriggerTime=-1;
                    event=event+1;
                case 'Instruction',
                    % this function shows an instruction on the screen for the subject
                    currInstr=par.INSTRUCTION{event};
                    VideoRecorder('message', ['Instruction'] );
                    goOn=showInstruction(window, currInstr, keyNames);
                    if goOn==0
                        break;
                    end
                case 'Fixation',
                    Screen('FillRect',window, gray);
                    drawFixationPoint(window, fixPtSize, fixPtCol);
                    Screen('TextFont',window, 'Arial');
                    Screen('TextSize',window, 12);
                    DrawFormattedText(window, '\n\nF', 'center', 'center', WhiteIndex(window));
                    VideoRecorder('message', ['Fixation'] );

                    stimPrepReady=1;
                    doFlip=1;
                    stimulusOnsetTime=-1;
                    actStimDur=-1;
                    stimulusDone=0;
                    stimulusOn=0;
                    waitForTrigger=1;

                case 'Movie',
                    % here we prepare the (movie) stimulus

                    moviename=[par.STIMDIR{event} filesep par.STIMULUS{event}];

                    % Open movie file and retrieve basic info about movie:
                    [movie movieduration fps imgw imgh] = Screen('OpenMovie', window, moviename);

                    %                     fprintf('Event %d, Movie: %s  , Duration: %f secs, %f fps\n', event, moviename, movieduration, fps);

                    VideoRecorder('message', ['StimulusMovie: ' moviename] );


                    % Seek to start of movie (timeindex 0):
                    Screen('SetMovieTimeIndex', movie, 0);
                    % playback rate =0;
%                     Screen('PlayMovie', movie, 1, 0, 1.0);
%                     WaitSecs(0.02);
%                     Screen('PlayMovie', movie, 0, 0, 1.0);
%                     Screen('SetMovieTimeIndex', movie, 0);

                    %                     [tex pts] = Screen('GetMovieImage', window, movie, 1)
                    %                     Screen('Close', tex);
                    movieStarted=0;
                    stimPrepReady=1;
                    stimulusOn=0;
                    stimulusDone=0;
                    stimulusOnsetTime=-1;
                    actStimDur=-1;
                    waitForTrigger=1;

                case 'Image',
                    imgname=[par.STIMDIR{event} filesep par.STIMULUS{event}];
                    imdata=imread(imgname);
                    tex=Screen('MakeTexture', window, imdata);
                    Screen('FillRect',window, gray);
                    Screen('DrawTexture', window, tex);
                    VideoRecorder('message', ['StimulusImage: ' imgname] );

                    doFlip=1;
                    stimPrepReady=1;
                    stimulusOn=0;
                    stimulusDone=0;
                    stimulusOnsetTime=-1;
                    actStimDur=-1;
                    waitForTrigger=1;
                otherwise,
                    disp([mfilename ' error: unknown event type ''' par.EVENTTYPE{event} ]);
            end
        end

        % wait for trigger, when stimulus is ready
        if waitForTrigger==1
            disp('Waiting for trigger');
            prevTriggerTime=triggerTime;
            [triggerTime goOn]=WaitForTrigger(triggerKey, quitKey, maxWait);
            disp('Trigger received');
            if firstTriggerTime<0
                firstTriggerTime=triggerTime;
                deltaTT=0;
            else
                deltaTT=triggerTime-prevTriggerTime;
            end
            eventEnd=triggerTime+(TR*par.EVENTDUR(event)-triggerWaitTime);

            eventStart=triggerTime-firstTriggerTime;
            VideoRecorder('message', ['EventStart: ' sprintf('%.2f', eventStart )]);
            VideoRecorder('message', ['EventEndExpected: ' sprintf('%.2f', eventStart+TR*par.EVENTDUR(event))]);
            VideoRecorder('message', ['TriggerInterval: ' sprintf('%.2f', deltaTT ) ' s.' ] );

            waitForTrigger=0;

            if goOn==0
                display('User requested break');
                break
            end
        end

        % response and display loop
        %         disp('resp and display loop');
        while GetSecs<eventEnd
            % draw next movie frame in case of a movie
            if 1==strcmp( par.EVENTTYPE{event}, 'Movie') && stimulusDone==0
                if movieStarted==0
%                                         Screen('SetMovieTimeIndex', movie, 0); % rewind
%                     WaitSecs(0.1);
                    Screen('PlayMovie', movie, rate, 0, 1.0);
                    Screen('FillRect', window, gray);
                    movieStarted=1;
                end
                [tex pts] = Screen('GetMovieImage', window, movie, 1);
                if tex<0
                    stimulusDone=1;
                else
                    % Draw the new texture to the screen:
                    Screen('DrawTexture', window, tex);
                    % Release texture
                    Screen('Close', tex);
                    doFlip=1;
                end
            end

            % check state of keyboard
            [keyIsDown, secs, keyCode] = KbCheck;
            [mx, my, buttons]=GetMouse(window);

            % test if the user wanted to stop the program

            if keyCode(quitKey) || any(buttons)
                display('User requested break');
                goOn=0;
                break
            end

            if stimulusOn>0
                % try to obtain a response once stimulus is on screen
                if keyIsDown==1 || any(buttons)
                    if keyCode(leftwardKey) || buttons(1)==1
                        response=1;
                    elseif keyCode(rightwardKey) || any(buttons)
                        response=2;
                    end
                end
            end

            if 1==strcmp( par.EVENTTYPE{event}, 'Image') && stimulusOn==1 && GetSecs>stimEnd
                stimulusDone=1;
            end

            % remove stimulus
            if stimulusDone==1
                if 1==strcmp( par.EVENTTYPE{event}, 'Movie')
                    % Close movie object
                    Screen('CloseMovie', movie);
                end
                Screen('FillRect', window, gray);
                drawFixationPoint(window, fixPtSize, fixPtCol);
                doFlip=1;
                stimulusDone=2;
            end

            % Update display
            if doFlip==1
                vbl=Screen('Flip', window, [], 2);
                doFlip=0;
                if stimulusOnsetTime<0
                    stimulusOnsetTime=vbl;
                    if 1==strcmp( par.EVENTTYPE{event}, 'Image')
                        stimEnd=vbl+(par.STIMDUR(event));
                    end
                    stimulusOn=1;
                    relStimulusOnSetTime=vbl-firstTriggerTime;
                    VideoRecorder('message', ['Stimulus on: ' sprintf('%.2f', relStimulusOnSetTime ) ] );
                    VideoRecorder('message', ['Stimulus delay: ' sprintf('%.2f', relStimulusOnSetTime-eventStart ) ] );

                end

                if stimulusDone==2 && stimulusOnsetTime>0 && actStimDur<0
                    actStimDur=vbl-stimulusOnsetTime;
                    stimulusOn=2;
                    VideoRecorder('message', ['Stimulus off: ' sprintf('%.2f', vbl-firstTriggerTime ) ] );
                    VideoRecorder('message', ['Actual stimulus duration: ' sprintf('%.2f', actStimDur ) ] );
                end

            end

            VideoRecorder('gettimestamp');
            
            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % shorter for more frequent sampling of keys
            WaitSecs(0.001);

        end
        stimPrepReady=0;


        % we now will save the data to a file
        % note that we now append ('a') to the file! We'll multiply the rt
        % and dl parameters by 1000 to get milliseconds. We immediately close the file
        % again (just in case). Note the different symbols used to print
        % out different types of parameters. %s for strings/letters, %d for
        % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
        if 0 && goOn==1
            fp=fopen(myfile, 'a'); % open with 'a' for appending info to existing file.
            time=datestr(now, 'HH-MM-SS'); %  record timestamp of response

            % we distribute printing over a number of  commands for
            % readability
            fprintf(fp, '%s\t%d\t%d\t%s\t%s\t', subject, session, event, date, time);
            fprintf(fp, '%s\t%.1f\t', currInstr, actStimDur);
            fprintf(fp, '%s', moviename);
            for k=1:length(rating)
                fprintf(fp, '\t%.1f', rating(k));
            end
            fprintf(fp, '\n');

            fclose(fp);

        end
        % increase the event number
        event=event+1;
    end

    VideoRecorder('message', ['End of experiment: ' sprintf('%.2f', GetSecs-firstTriggerTime ) ] );
    WaitSecs(2);
    disp('stop recording');
    VideoRecorder('stoprecording');

    Priority(oldPriority);

    % display a message indicating that the experiment has finished
    if goOn==1
        disp('The experiment has been completed, thanks for participating!');
    else
        % in case of a break, some other message might be more appropriate
        disp('Please contact the experiment leader immediately, thanks!');
    end

    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);
    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    diary off

    %     This "catch" section executes in case of an error in the "try" section
    %     above.  Importantly, it closes the onscreen window if it''s open.
catch

    Eyelink('ShutDown');
    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);

    Screen('CloseAll');
    ShowCursor;

    Priority(0);

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



function goOn=WaitForScanner(window, keyNames)

% wait for scanner
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

goOn=1; % do not continue with experiment

tstring='Waiting for scanner';

tstring=[tstring '\n\n\n\n'];
tstring=[tstring 'Press the ''' keyNames.triggerKey ''' key to advance\n'];
tstring=[tstring 'Press the ''' keyNames.quitKey ''' key to abort,\n'];


Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1);


DrawFormattedText(window, tstring, 'center', 'center', WhiteIndex(window));
Screen('Flip', window, [], 2);

% goOn=WaitForTrigger(maxWait, keyNames);

% erase the screen
% Screen('FillRect', window, GrayIndex(window));
% Screen('Flip', window);


function [tt goOn]=WaitForTrigger(triggerKey, quitKey, maxWait)

% wait for trigger from scanner
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment.

goOn=0; % do not continue with experiment

% wait for key release
while KbCheck
    WaitSecs(0.001);
end

% quitKey=KbName(keyNames.quitKey);
% triggerKey=KbName(keyNames.triggerKey);
%
endWait=GetSecs+maxWait;
% wait for key press
while GetSecs<endWait
    [keyIsDown,tt,keyCode] = KbCheck;

    % check if a key was pressed
    if keyIsDown==1
        % test if the user wanted to stop
        if keyCode(quitKey)
            %             display('User requested break');
            break;
        elseif keyCode(triggerKey)
            %             display('Trigger received');
            goOn=1; % okidoki
            break;
        end
    end
    WaitSecs(0.01);
end





