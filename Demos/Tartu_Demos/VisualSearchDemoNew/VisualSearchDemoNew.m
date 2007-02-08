function VisualSearchDemo(subject, session, parfile)
% visual search experiment demo
% shows how to measure simple choice RT
% shows the basic organization of a visual search experiment
% shows how to save measured responses to a tab delimited file.
% shows how to use functions to do part of the job
% shows how to get some info via variables, or via prompt
% add ability to read in info via a parameter file
% shows how to do display timing using Screen's flip command

% the parameter file should be in directory 'parfiles'
% and contain the following columns
% stimSize: stimulus size, in percentage of screen width
% stimTime: stimulus time, in ms
% objSizeH, objSizeV: hor and vert object size, in percentage of screen width
% target: 'yes' for target present, anything else will result in no target


% Tartu Matlab & PsychToolbox course, Januari 2007, Tartu, Estonia
% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 10-01-07  fwc created, based on savefiledemo.m and VisualSearchDemo.m
% 11-01-07  fwc further adaptations and improvements

commandwindow;

if ~exist('subject', 'var') | isempty(subject)
    subject=input('Subject name (''name'')? ');
    if isempty(subject)
        disp('Experiment stopped');
        return;
    end
end

if ~exist('session', 'var') | isempty(session)
    session=input('Session nr (number)? ');
    if isempty(session)
        disp('No session nr given, experiment stopped');
        return;
    end
end
if ~isnumeric(session)
    disp('Session should be a number, experiment stopped');
    return
end

if ~exist('parfile', 'var') | isempty(parfile)
    parfile=input('Parameter file (''filename'')? ');
    if isempty(parfile)
        disp('No parameter file given, experiment stopped');
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
    myparfile=[myparfiledir filesep parfile '.txt']; % construct parfile name
    par=autotextread(myparfile);

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
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=1500; % minimal inter trial interval, in secs
    baseAngle=45;
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;

    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.targetPresentKey='m';
    keyNames.targetAbsentKey='c';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    targetPresentKey=KbName(keyNames.targetPresentKey);
    targetAbsentKey=KbName(keyNames.targetAbsentKey);

    % here, we specify the filename of the output file, and we print the header
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!
    mydatadir='data';
    myfile=[mydatadir filesep subject '_' num2str(session) '_' parfile '_' mfilename '_data' '.txt']; % create a meaningful name

    fp=fopen(myfile, 'w'); % 'w' for write which creates a new file always, alternative would be 'a' for append.
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tDELAY\tACTCUETIME\tACTSOA\tACTSTIMDUR\tPRESENT\tTARGET\tRESP\tRT\n');
    fclose(fp);

    % here we open a window and paint it gray
    [window, winrect]=Screen('OpenWindow',screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',window, gray);
    Screen('Flip', window);
    monitorRefreshInterval =Screen('GetFlipInterval', window);
    HideCursor;

    % this function shows an instruction on the screen for the subject
    % instruction is defined in this function
    goOn=showInstruction(window, keyNames);

    % this is the start of the trial loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file

    nrTrials=length(par.stimTime); % use length of one of the paramater vectors to determine the number of trials
    i=1; % initialize trial number
    itiEnd=GetSecs+itiTime/1000*2; % set iti to double duration for the first trial

    while goOn==1 & i<=nrTrials

        % we'll wait to make sure the subject
        % released any keys, before starting a new trial
        % moreover, we make sure a certain amount of time (itiTime) has
        % passed before starting the new trial by waiting until itiEnd

        while GetSecs<itiEnd | KbCheck
            WaitSecs(0.01);
        end

        % mark start of a new trial by showing the fixation point
        Screen('FillRect', window, gray);
        % seperate function for drawing fixation point, so we can reuse it
        drawFixationPoint(window, fixPtSize, fixPtCol); % show fixation point
        [notUsed delayOnsetTime]=Screen('Flip', window);
        % determine a random delay between .5 and 1 secs.
        tDelayEnd=delayOnsetTime+0.5+rand*0.5;

        % part of the information for creating the stimulus now comes from
        % the parameter file/par structure. Here we get this information, or convert it
        % into the appropriate format.

        % determine stim type (target present or absent)
        if strcmp(par.target(i), 'yes')==1
            stimType=1;
        else
            stimType=0;
        end

        nObjects=par.nDistractors(i)*3+1;
        objSize=[par.objSizeH(i) par.objSizeV(i)];
        delta=par.color(i);
        red=[gray+delta gray-delta gray];  % we specify two possible object colours, red and green
        green=[gray-delta gray+delta gray];
        objCols=[red; green]; % possible object colors
        objAngles=[par.tilt(i) -par.tilt(i)]; % possible object angles
        objAngles=objAngles+baseAngle;

        % set stimulus properties, for clarity,
        % we offload this task to a seperate function
        [aList, cList, target, tAng, tCol]=setStimulusProperties(par.nDistractors(i), stimType);

        % prepare and present cue,
        % i.e. the target centered on screen
        % we offload this task to a seperate function
        % and record cue onset time provided by
        % screen's flip command
        % calculate intended end of cue display and soa
        % We subtract half a refresh interval, so the
        % stimulus time should not exceed requested presentation time

        createCue(window, objSize, objCols(tCol,:), objAngles(tAng) );
        [notUsed cueOnsetTime]=Screen('Flip', window, tDelayEnd);
        actDelayDur=cueOnsetTime-delayOnsetTime;
        tCueEnd=cueOnsetTime+par.cueTime(i)/1000-monitorRefreshInterval/3; % set end of cue display
        tSoaEnd=cueOnsetTime+par.soa(i)/1000-monitorRefreshInterval/3; % set end of stimulus onset asynchrony

        % we can already prepare next screen
        % as it won't show until we issue a flip command
        % we tell screen's flip command to wait until end of the cue time to erase screen

        Screen('FillRect', window, gray);
        drawFixationPoint(window, fixPtSize, fixPtCol); % leave fixation point

        [notUsed cueOffsetTime]=Screen('Flip', window, tCueEnd);
        actCueDur=cueOffsetTime-cueOnsetTime;

        % prepare stimulus screen, by a seperate function
        % and wait until end of the stimulus onset asynchrony time to
        % display stimulus on screen, screen's flip command also returns the
        % stimulus onset time
        createStimulus(window, par.stimSize(i), nObjects, objSize, objCols, objAngles, cList, aList );
        if 0
            createCue(window, gray, objSize, objCols(tCol,:), objAngles(tAng) );
            if stimType==0 % no target present
                target=0;
                tarPres='no';
            else
                tarPres='yes';
            end

            DrawFormattedText(window, tarPres, 'center', 'center', WhiteIndex(window));

        end
        drawFixationPoint(window, fixPtSize, fixPtCol);
        [notUsed StimulusOnsetTime]=Screen('Flip', window, tSoaEnd);

        % calculate end of 'stimulus display, and store stimulus onset time for reaction
        % time measurement. We subtract half a refresh interval, so the
        % stimulus time should not exceed requested presentation time
        tStimEnd=StimulusOnsetTime+par.stimTime(i)/1000-monitorRefreshInterval;
        actSoaDur=StimulusOnsetTime-cueOnsetTime;
        actStimDur=-999; % initialize for later storage of actual stimulus duration

        % this is the start of the response loop
        % in it, we also check if we need to remove the stimulus

        while 1

            % check if we need to remove the stimulus
            % we  test whether actStimDur has still its initialization
            % value, indicating stimulus presentation has not ended yet.
            if GetSecs>tStimEnd & actStimDur < 0
                % time passed, remove stimulus!
                Screen('FillRect',window, gray);
                drawFixationPoint(window, fixPtSize, fixPtCol); % leave fixation point
                [notUsed StimulusOffsetTime]=Screen('Flip', window, tStimEnd+monitorRefreshInterval/2);
                actStimDur=StimulusOffsetTime-StimulusOnsetTime; % calculate actual stimulus duration
            end

            % check state of keyboard
            [keyIsDown,secs,keyCode] = KbCheck;

            % we'll only go into the code below if a key was pressed
            if keyIsDown==1
                % test if the user wanted to stop the program
                if keyCode(quitKey)
                    display('User requested break');
                    response='no';
                    rt=-999;
                    goOn=0;
                    break;
                end
                % otherwise test if one of the specified response keys was pressed
                if keyCode(targetAbsentKey)==1
                    response='no'; % record response
                    rt=secs-StimulusOnsetTime; % determine reaction time
                    break;
                elseif keyCode(targetPresentKey)==1
                    response='yes';
                    rt=secs-StimulusOnsetTime;
                    break;
                end
            end

            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % shorter for more frequent sampling of keys
            WaitSecs(0.001);
        end

        % set the end of the inter trial interval
        itiEnd=GetSecs+itiTime/1000;

        % erase screen after response
        % if response is very fast, the stimulus has not been erased yet.
        Screen('FillRect',window, gray);
        drawFixationPoint(window, fixPtSize*2, fixPtCol); % we grow fix point to show response was recorded
        [notUsed StimulusOffsetTime]=Screen('Flip', window);
        % if actual stimulus duration was not yet calculated, we do this
        % here.
        if actStimDur<0
            actStimDur=StimulusOffsetTime-StimulusOnsetTime;
        end

        % if we got an actual response, we now will save the data to a file
        % note that we now append ('a') to the file! We'll multiply the rt
        % and dl parameters by 1000 to get milliseconds. We immediately close the file
        % again (just in case). Note the different symbols used to print
        % out different types of parameters. %s for strings/letters, %d for
        % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
        if goOn==1
            fp=fopen(myfile, 'a'); % open with 'a' for appending info to existing file.
            if stimType==0 % no target present
                target=0;
                tarPres='no';
            else
                tarPres='yes';
            end
            date=datestr(now, 'dd.mm.yyyy'); % record date of response
            time=datestr(now, 'HH:MM:SS'); % also record timestamp of response

            % we distribute printing over a number of  commands for
            % readability
            fprintf(fp, '%s\t%d\t%d\t%s\t%s\t', subject, session, i, date, time);
            fprintf(fp, '%.1f\t%.1f\t%.1f\t%.1f\t', actDelayDur*1000, actCueDur*1000, actSoaDur*1000, actStimDur*1000);
            fprintf(fp, '%s\t%d\t%s\t%.1f\n', tarPres, target, response, rt*1000);
            fclose(fp);

        end
        % increase the trial number
        i=i+1;
    end

    % display a message indicating that the experiment has finished
    if goOn==1
        disp('The experiment has been completed, thanks for participating!');
    else
        % in case of a break, some other message might be more appropriate
        disp('Please contact the experiment leader immediately, thanks!');
    end

    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
catch

    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    psychrethrow(psychlasterror);
end


function [ang, col, target, tAng, tCol]=setStimulusProperties(nrDistr, showTarget)
% function for setting stimulus properties (ha ;-)
if showTarget==1
    [obj, target]=setObjects(nrDistr);
else
    [obj, target]=setObjects(nrDistr, 0);
end
v=randperm(2);
tAng=v(1);
dAng=v(2);

v=randperm(2);
tCol=v(1);
dCol=v(2);

[ang, col]=setObjectProp(obj, tAng, tCol, dAng, dCol);

function [obj, target]=setObjects(nrDistr, target)
% function for determining object properties (in a generic manner)
distrTypes=3;
nrObj=distrTypes*nrDistr+1;
obj=zeros(nrObj,1);

% determine target position
if ~exist('target', 'var') | isempty(target)
    target=randperm(nrObj);
    target=target(1);
    obj(target)=1;
elseif target==0 % indicates no target, we assign a random distractor type
    target=randperm(nrObj);
    target=target(1);
    temp=randperm(distrTypes);
    obj(target)=temp(1)+1;
else
    obj(target)=1;
end

% determine the random position(s) for each distractor type
for i=1:distrTypes
    for j=1:nrDistr
        while 1
            pos=randperm(nrObj);
            if obj(pos(1))==0
                obj(pos(1))=1+i; % set type of distractor for this object number
                break
            end
        end
    end
end

function [ang, col]=setObjectProp(obj, tAng, tCol, dAng, dCol)
% function for assigning actual object properties

for i=1:length(obj)
    switch(obj(i))
        case 1,
            ang(i)=tAng;
            col(i)=tCol;
        case 2,
            ang(i)=tAng;
            col(i)=dCol;
        case 3,
            ang(i)=dAng;
            col(i)=tCol;
        case 4,
            ang(i)=dAng;
            col(i)=dCol;
    end
end

function createCue(window, objSize, objCol, objAngle )
% create cue for target
[h v]=WindowSize(window);
objSize=round(objSize/100*h); % objSize contains both hor and vert size
rect=[0 0 objSize];
% we use a offscreenwindow-texture to draw a bar, useful for constant shape and rotation
[tex texRect]=Screen('OpenOffscreenWindow', window, objCol, rect);

dRect=CenterRectInWindow(texRect, window); % center cue position
Screen('DrawTexture', window, tex, [], dRect, objAngle);
% close texture to free memory
Screen('Close', tex); % closes all textures


function createStimulus(window, stimSize, nrObj, objSize, objCol, objAngle, cLst, aLst )
% create actual search stimulus
[h v]=WindowSize(window);
objSize=round(objSize/100*h);

rect=[0 0 objSize];

% we use a offscreenwindow-texture to draw a bar, useful for constant shape and rotation
[tex(1) texRect(1,:)]=Screen('OpenOffscreenWindow',window ,objCol(1,:) ,rect);
[tex(2) texRect(2,:)]=Screen('OpenOffscreenWindow',window ,objCol(2,:) ,rect);

stimSize=stimSize/100*h;

posAng=linspace(0, 360, nrObj+1);
posAng=posAng(1:end-1);
[x0 y0]=WindowCenter(window);

xpos=x0+round(stimSize*cos(posAng*pi/180));
ypos=y0+round(stimSize*sin(posAng*pi/180));

for i=1:length(posAng)
    dRect=CenterRectOnPoint(texRect(cLst(i),:), xpos(i), ypos(i));
    Screen('DrawTexture', window, tex(cLst(i)), [], dRect, objAngle(aLst(i)));

end

% close texture to free memory
Screen('Close'); % closes all textures




function drawFixationPoint(window, fpSize, fpCol);
[h v]=WindowSize(window);
fpSize=round(fpSize/100*h);
[x0 y0]=WindowCenter(window);
fpRect=CenterRectOnPoint([0 0 fpSize fpSize], x0, y0);

Screen('FillOval', window, fpCol, fpRect);



function goOn=showInstruction(window, keyNames)

% show instruction on screen
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

tstring=['Welcome to this visual search experiment\n\n'];
tstring=[tstring 'Press the ''' keyNames.targetPresentKey ''' for target present\n'];
tstring=[tstring 'Press the ''' keyNames.targetAbsentKey ''' for target absent\n\n'];
tstring=[tstring 'Press the ''' keyNames.quitKey ''' key to abort,\n'];
tstring=[tstring 'any other key to continue'];


Screen('TextFont',window, 'Courier');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1+2);


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
