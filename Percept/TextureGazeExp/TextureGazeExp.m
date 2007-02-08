function TextureGazeExp(subject, session, parfile)
% texture gaze and saliency experiment

% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 18-01-07  fwc created

commandwindow;
cd(FunctionFolder(mfilename));
diary('TextureGazeExpLog.txt');

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
    mss=h*v
    for i=1:length(screens)  % but use bigger screen if there is one ;-)
        [h v]=WindowSize(screens(i));
        if h*v>mss
            mss=h*v
            screenNumber=screens(i)
        end
    end


    %     screenNumber=max(screens);
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % likely to change with every trial
    itiTime=1500; % minimal inter trial interval, in secs
    fixPtSize=1; % fixation point size, in percentage of screen size
    fixPtCol=white;

    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.leftwardKey='m';
    keyNames.rightwardKey='c';

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
    fprintf(fp, 'SUBJECT\tSESSION\tTRIAL\tDATE\tTIME\tDELAY\tACTCUETIME\tACTSOA\tACTSTIMDUR\tPRESENT\tTARGET\tRESP\tRT\n');
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

    % this is the start of the trial loop
    % consisting of stimulus creation, stimulus display,
    % response loop, and saving of response to a file

    nrTrials=length(par.imageDir); % use length of one of the parameter vectors to determine the number of trials
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
        tDelayEnd=delayOnsetTime+0.05+rand*0.05;

        % prepare stimulus , in a seperate function
        % most of the information for creating the stimulus now comes from
        % the parameter file/par structure.
        % and wait until end of the stimulus onset asynchrony time to
        % display stimulus on screen, screen's flip command also returns the
        % stimulus onset time

        % this function prepares the stimulus
        % it won't show until we issue a flip command
        imageDir=['images' filesep par.imageDir{i}];
        [imgfiles, nStim, xpos, ypos]=createImageStimulus(window, imageDir, par.nrStimuli(i), par.stimRadius(i), par.stimSize(i), par.stimOrient(i), par.maskSD(i));
        %         targets=addSearchStimulus(window, xpos, ypos, par.targetSize(i), par.targetTrans(i) );
        % add fixationPoint
        drawFixationPoint(window, fixPtSize, fixPtCol);

        [notUsed stimulusOnsetTime]=Screen('Flip', window, tDelayEnd);
        actDelayDur=stimulusOnsetTime-delayOnsetTime;
        tStimEnd=stimulusOnsetTime+par.stimDur(i)/1000;
        actStimDur=-999; % initialize for later storage of actual stimulus duration


        %         pause
        % this is the start of the response loop
        % in it, we also check if we need to display the next frame of the
        % movie

        while 1

            % check if we need to show the next frame of our movie stimulus
            % we  test whether mfi (movieFrameIndex) is less than number of
            % frame to show, indicating stimulus presentation has not ended yet.
            if GetSecs>tStimEnd & actStimDur<0
                % time passed, show next frame!
                Screen('FillRect', window, gray);
                drawFixationPoint(window, fixPtSize, fixPtCol);

                [notUsed stimulusOffsetTime]=Screen('Flip', window, tStimEnd);
                actStimDur=stimulusOffsetTime-stimulusOnsetTime;
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
                if keyCode(leftwardKey)==1
                    response='left'; % record response
                    rt=secs-stimulusOnsetTime; % determine reaction time
                    break;
                elseif keyCode(rightwardKey)==1
                    response='right';
                    rt=secs-stimulusOnsetTime;
                    break;
                end
            end

            % return control to the OS for a short time, to keep it happy.
            % we may loose real-time priority if we do not. Make this time
            % shorter for more frequent sampling of keys
            %             WaitSecs(0.001);
        end

        % set the end of the inter trial interval
        itiEnd=GetSecs+itiTime/1000;

        % erase screen after response
        % if response is very fast, the stimulus has not been erased yet.
        Screen('FillRect',window, gray);
        drawFixationPoint(window, fixPtSize*2, fixPtCol); % we grow fix point to show response was recorded
        [notUsed stimulusOffsetTime]=Screen('Flip', window);
        % if actual stimulus duration was not yet calculated, we do this
        % here.
        if actStimDur<0
            actStimDur=stimulusOffsetTime-stimulusOnsetTime;
        end

        Screen('Close'); % this will close all textures of the motion movie


        % if we got an actual response, we now will save the data to a file
        % note that we now append ('a') to the file! We'll multiply the rt
        % and dl parameters by 1000 to get milliseconds. We immediately close the file
        % again (just in case). Note the different symbols used to print
        % out different types of parameters. %s for strings/letters, %d for
        % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
        if goOn==1
            fp=fopen(myfile, 'a'); % open with 'a' for appending info to existing file.
            date=datestr(now, 'dd.mm.yyyy'); % record date of response
            time=datestr(now, 'HH:MM:SS'); % also record timestamp of response

            % we distribute printing over a number of  commands for
            % readability
            fprintf(fp, '%s\t%d\t%d\t%s\t%s\t', subject, session, i, date, time);
            fprintf(fp, '%.1f\t%.1f\t%.1f\t%.1f\t', actDelayDur*1000, -999*1000, -999*1000, actStimDur*1000);
            fprintf(fp, '%s\t%d\t%s\t%.1f\n', 'dummy', -999, response, rt*1000);
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



%
%
% function drawFixationPoint(window, fpSize, fpCol);
% [h v]=WindowSize(window);
% fpSize=round(fpSize/100*h);
% [x0 y0]=WindowCenter(window);
% fpRect=CenterRectOnPoint([0 0 fpSize fpSize], x0, y0);
%
% Screen('FillOval', window, fpCol, fpRect);
%


function goOn=showInstruction(window, keyNames)

% show instruction on screen
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

tstring=['Welcome to this search experiment\n\n'];
tstring=[tstring 'Press the ''' keyNames.leftwardKey ''' for nice stimuli\n'];
tstring=[tstring 'Press the ''' keyNames.rightwardKey ''' for ugly stimuli\n\n'];
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


function [myimgfile, nStim, xpos, ypos, gapangle]=createImageStimulus(window, imageDir, nStim, radius, siz, ori, masksd )

white=WhiteIndex(window);
black=BlackIndex(window);
gray=GrayIndex(window);

%     We create a Luminance+Alpha matrix for use as a transparency mask:

ms=100;
[x,y]=meshgrid(-ms:ms, -ms:ms);
% maskvariance=masksd;
maskvariance=2.2;
xsd=ms/maskvariance;
ysd=ms/maskvariance;
mask=uint8(round(exp(-((x/xsd).^2)-((y/ysd).^2))*white));

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

% randomly pick nStimuli
stimuli=stimuli(randperm(length(stimuli))); % prevents each texture from appearing more than once
stimuli=stimuli(1:min(nStim,length(stimuli)));

% create texture of each image
j=1;
for i=stimuli
    myimgfile{j}=fullfile(imageDir,dirList(i).name);
%     fprintf('Loading image ''%s''\n', myimgfile{j});
    imdata=imread(myimgfile{j});
    transLayer=size(imdata,3)+1;
    imdata(:,:,transLayer)=mask;
    tex(j)=Screen('MakeTexture', window, imdata);
    j=j+1;
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

lct=landoltCTexture(window, 2*siz+1, GrayIndex(window,0.55), gray, 'right');
gapangle=linspace(0,360,length(xpos)+1);
gapangle=gapangle(1:end-1);
gapangle=gapangle(randperm(length(gapangle)));

for i=1:length(tex)

    dRect=CenterRectOnPoint(rect, xpos(i), ypos(i));

    Screen('DrawTexture', window, lct, [], dRect, gapangle(i));

    texAngle=-ori+2*rand*ori;

    %     rect=Screen('Rect', tex(i));



    Screen('DrawTexture', window, tex(i), [], dRect, texAngle);
end
% close textures to free memory
Screen('Close'); % closes all textures

nStim=length(tex);




function targets=addSearchStimulus(window, xpos, ypos, size, transparency )


white=WhiteIndex(window);
black=BlackIndex(window);
gray=GrayIndex(window);
delta=40;
color=[gray+delta gray-delta gray];
color=GrayIndex(window,0.55);
[h v]=WindowSize(window);

size=round(size/100*h);

rect=[0 0 size size];
gaps={'top','bottom','right','left', 'horizontal', 'vertical'}; % options for
gapor=randperm(4);
gapor=gapor(1);
gapor=3;

ttex=Screen('OpenOffscreenWindow', window, black, rect);
[x0 y0]=WindowCenter(ttex);
landoltC(ttex, x0, y0, size, color, black, gaps{gapor});
imdata=Screen('GetImage', ttex);

imdata=imdata;
imdata(:,:,4)=imdata(:,:,1)*(1-transparency/100);
ttex2=Screen('MakeTexture', window, imdata);

% gap=gaps{gapor};
% ttex2=landoltCTexture(window, size, color, transparency, gap);

rect=Screen('Rect', ttex2);

targets=randperm(length(xpos)); % select two targets
targets=targets(1:2);

gapangle=linspace(0,360,length(xpos)+1);
gapangle=gapangle(1:end-1);


for i=1:length(xpos)
    %     gapangle=0;
    dRect=CenterRectOnPoint(rect, xpos(i), ypos(i));
    %     Screen('DrawTexture', window, ttex2, [], dRect, gapangle(i));

    %      landoltC(window, xpos(i), ypos(i), size, color, background, gap)
end

% close textures to free memory
Screen('Close'); % closes all textures



function lct=landoltCTexture(window, size, color, background, gap)

rect=[0 0 size size];
lct=Screen('OpenOffscreenWindow', window, background, rect);
[x0 y0]=WindowCenter(lct);
landoltC(lct, x0, y0, size, color, background, gap);

function lct=landoltCTexture2(window, size, color, transparency, gap)

black=BlackIndex(window);
rect=[0 0 size size];
ttex=Screen('OpenOffscreenWindow', window, black, rect);
[x0 y0]=WindowCenter(ttex);
landoltC(ttex, x0, y0, size, color, black, gap);
imdata=Screen('GetImage', ttex);
imdata=imdata;
% mask=zeros(size(imdata));
imdata(:,:,4)=imdata(:,:,1)*(1-transparency/100); % set alpha value
lct=Screen('MakeTexture', window, imdata);
Screen('Close', ttex);



function addSearchStimulus2(window, xpos, ypos, size, transparency )


white=WhiteIndex(window);
black=BlackIndex(window);
gray=GrayIndex(window);

[h v]=WindowSize(window);

size=round(size/100*h)

rect=[0 0 size size];
gap='no';
ttex=Screen('OpenOffscreenWindow', window, black, rect);
[x0 y0]=WindowCenter(ttex);
landoltC(ttex, x0, y0, size, white, black, gap)

imdata=Screen('GetImage', ttex);

imdata=imdata;
imdata(:,:,4)=imdata(:,:,1)*(transparency/100);
ttex2=Screen('MakeTexture', window, imdata);

rect=Screen('Rect', ttex2);

for i=1:length(xpos)
    dRect=CenterRectOnPoint(rect, xpos(i), ypos(i));
    Screen('DrawTexture', window, ttex2, [], dRect);

    %     landoltC(window, xpos(i), ypos(i), size, color, background, gap)
end

% close textures to free memory
Screen('Close'); % closes all textures



