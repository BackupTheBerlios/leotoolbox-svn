function VisualSearchDemo(subject, session)
% visual search experiment demo
% shows how to measure simple choice RT
% shows the basic organization of a visual search experiment
% shows how to save measured responses to a tab delimited file.
% shows how to use functions to do part of the job
% shows how to get some info via variables, or via prompt

% Tartu Matlab & PsychToolbox course, Januari 2007, Tartu, Estonia
% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 09-01-07  fwc created, based on savefiledemo.m

commandwindow;
oldPriority=0;

if ~exist('subject', 'var') | isempty(subject)
    subject=input('Subject name (''name'')? ');
    if isempty(subject)
        disp('Experiment stopped');
        return;
    end
end

if ~exist('session', 'var') | isempty(session)
    session=input('Session name (''name'')? ');
    if isempty(session)
        disp('No session given, experiment stopped');
        return;
    end
    if isnumber(session)
        session=num2str(session);
    end
   
end

try

    % suppress warnings
    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);

    screens=Screen('Screens');
    screenNumber=max(screens);
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);


    % here we specify a number of important experimental variables
    nrTrials=10;
    nrDistr=3; % how many of each distractor type?
    nObjects=3*nrDistr+1;
    stimSize=30; % stimulus size, in percentage of screen width
    stimTime=0.5;   % stimulus duration, in secs
    itiTime=1.0; % minimal inter trial interval, in secs
    objSize=[8 2]; % hor and vert object size, in percentage of screen width
    delta=30;
    red=[gray+delta gray-delta gray];  % we specify two possible object colours, red and green
    green=[gray-delta gray+delta gray];
    objCols=[red; green]; % possible object colors
    objAngles=[15 -15]; % possible object angles
    baseAngle=45;
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;

    % here we specify our response keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    quitKey=KbName('ESCAPE');
    leftKey=KbName('c');
    rightKey=KbName('m');
    go_on=1;
    objAngles=objAngles+baseAngle;
    % here, we specify the filename, and we print the header of the output file
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!
    mydatadir='data';
    myfile=[mydatadir filesep subject '_' session '_' mfilename '_output' '.txt']; % create a meaningful name
    
    fp=fopen(myfile, 'w');
    fprintf(fp, 'SUBJECT\tDATETIME\tTRIAL\tDELAY\tACTSTIMDUR\tTARGET\tKEY\tRT\n');
    fclose(fp);


    % determine type of stimulus display
    % half the trials we will show target, on other half right not
    stimType=randperm(nrTrials);
    stimType=stimType>round(nrTrials/2);


    % here, we print a short instruction for the subject

    disp('Welcome to this visual search experiment');
    disp('Press the left key if there is a target present');
    disp('Press the right key if there is NO target present');
tstring='Welcome to this visual search experiment';

    [nx, ny, textbounds] = DrawFormattedText(window, tstring, sx, sy, color, wrapat)

    % here we open a window and paint it gray
    [window, winrect]=Screen('OpenWindow',screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',window, gray);
    Screen('Flip', window);
    monitorRefreshInterval =Screen('GetFlipInterval', window);
    HideCursor;
    % Bump priority for speed
%     priorityLevel=MaxPriority(window)
%     oldPriority=Priority(priorityLevel);

    % this is the start of the trial loop
    % consisting of stimulus creation, stimulus display, response loop, and saving of response to
    % a file
    i=1; % initialize trial number
    itiEnd=GetSecs; % first time around, we can start right away
    while go_on==1 & i<=nrTrials

        % we'll wait to make sure the subject
        % released any keys, before starting a new trial
        % moreover, we make sure a certain amount of time (itiTime) has
        % passed before starting the new trial

        while GetSecs<itiEnd | KbCheck
            WaitSecs(0.01);
        end

        Screen('FillRect', window, gray);
        drawFixationPoint(window, fixPtSize, fixPtCol); % leave fixation point
        Screen('Flip', window);

        % determine a random delay between .5 and 1 secs.
        dl=0.5+rand*0.5;
        WaitSecs(dl);

        % set stimulus properties, for clarity, we offload this task to a seperate function
        [aList, cList, target]=setStimulusProperties(nrDistr, stimType(i));
        % create stimulus, for clarity, we offload this task to a seperate function
        createStimulus(window, gray, stimSize, nObjects, objSize, objCols, objAngles, cList, aList );
        % seperate function for drawing fixation point, so we can reuse it
        drawFixationPoint(window, fixPtSize, fixPtCol);

        % show stimulus on screen
        [notUsed StimulusOnsetTime]=Screen('Flip', window);
        % calculate end of 'stimulus display, and store zero time for reaction
        % time measurement
        tEnd=StimulusOnsetTime+stimTime-monitorRefreshInterval;
        actStimDur=-999;
        % this is the start of the response loop
        while 1

            % first, we check if we need to remove the stimulus
            if GetSecs>tEnd & actStimDur < 0
                % time passed, remove stimulus!
                Screen('FillRect',window, gray);
                drawFixationPoint(window, fixPtSize, fixPtCol); % leave fixation point
                [notUsed StimulusOffsetTime]=Screen('Flip', window);
                actStimDur=StimulusOffsetTime-StimulusOnsetTime;
            end

            [keyIsDown,secs,keyCode] = KbCheck;

            % we'll only go into the below if a key was pressed
            if keyIsDown==1
                % test if the user wanted to stop the program
                if keyCode(quitKey)
                    display('User requested break');
                    respkey=-1;
                    rt=-999;
                    go_on=0;
                    break;
                end
                % otherwise test if one of the specified response keys was pressed
                if keyCode(leftKey)==1
                    respkey='left';
                    rt=secs-StimulusOnsetTime;
                    break;
                elseif keyCode(rightKey)==1
                    respkey='right';
                    rt=secs-StimulusOnsetTime;
                    break;
                end
            end

            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % shorter for more frequent sampling of keys
            WaitSecs(0.005);
        end

        % start timer for measuring the inter trial interval
        itiEnd=GetSecs+itiTime;

        % erase screen after response
        Screen('FillRect',window, gray);
        drawFixationPoint(window, fixPtSize*2, fixPtCol); % we grow fix point to show response was recorded
        [notUsed StimulusOffsetTime]=Screen('Flip', window);
        if actStimDur<0
            actStimDur=StimulusOffsetTime-StimulusOnsetTime;
        end

        % if we got an actual response, we now will save the data to a file
        % note that we now append ('a') to the file! We'll multiply the rt
        % and dl parameters by 1000 to get milliseconds. We immediately close the file
        % again (just in case). Note the different symbols used to print
        % out different types of parameters. %s for strings/letters, %d for
        % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
        if go_on==1
            fp=fopen(myfile, 'a');
            if stimType(i)==0 % no target present
                target=0;
            end
            date=datestr(now, 'dd_mm_yyyy_HH_MM_SS'); % also record date + timestamp of response
            fprintf(fp, '%s\t%s\t%d\t%.1f\t%.1f\t%d\t%s\t%.1f\n', subject, date, i, dl*1000, actStimDur*1000, target, respkey, rt*1000);
            fclose(fp);

        end


        % increase the trial number
        i=i+1;
    end

    % display a message indicating that the experiment has finished
    if go_on==1
        disp('The experiment is completed, thanks for participating!');
    else
        % in case of a break, some other message might be more appropriate
        disp('Please contact the experiment leader immediately, thanks!');
    end

    Screen('CloseAll');
    ShowCursor;
%     Priority(oldPriority);

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.
catch

    Screen('CloseAll');
    ShowCursor;
%     Priority(oldPriority);

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

    psychrethrow(psychlasterror);
end


function [ang, col, target]=setStimulusProperties(nrDistr, showTarget)

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
distrTypes=3;
nrObj=distrTypes*nrDistr+1;
obj=zeros(nrObj,1);

if ~exist('target', 'var') | isempty(target)
    target=randperm(nrObj);
    target=target(1);
    obj(target)=1;
elseif target==0
    target=randperm(nrObj);
    target=target(1);
    temp=randperm(distrTypes);
    obj(target)=temp(1)+1;
else
    obj(target)=1;
end

for i=1:distrTypes
    for j=1:nrDistr
        while 1
            pos=randperm(nrObj);
            if obj(pos(1))==0
                obj(pos(1))=1+i; % occupado
                break
            end
        end
    end
end

function [ang, col]=setObjectProp(obj, tAng, tCol, dAng, dCol)

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



function createStimulus(window, backCol, stimSize, nrObj, objSize, objCol, objAngle, cLst, aLst )

[h v]=WindowSize(window);
objSize=round(objSize/100*h);

rect=[0 0 objSize];

[tex(1) texRect(1,:)]=Screen('OpenOffscreenWindow',window ,objCol(1,:) ,rect);
[tex(2) texRect(2,:)]=Screen('OpenOffscreenWindow',window ,objCol(2,:) ,rect);

stimSize=stimSize/100*h;

posAng=linspace(0, 360, nrObj+1);
posAng=posAng(1:end-1);
[x0 y0]=WindowCenter(window);

xpos=x0+round(stimSize*cos(posAng*pi/180));
ypos=y0+round(stimSize*sin(posAng*pi/180));

length(posAng);

for i=1:length(posAng)
    dRect=CenterRectOnPoint(texRect(cLst(i),:), xpos(i), ypos(i));
    Screen('DrawTexture', window, tex(cLst(i)), [], dRect, objAngle(aLst(i)));

end





function drawFixationPoint(window, fpSize, fpCol);
[h v]=WindowSize(window);
fpSize=round(fpSize/100*h);
[x0 y0]=WindowCenter(window);
fpRect=CenterRectOnPoint([0 0 fpSize fpSize], x0, y0);

Screen('FillOval', window, fpCol, fpRect);

