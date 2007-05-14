function videoRecord4Presentation(subject, session)
%  video recorder that should run in parallel with Presentation

% History
% april 07  fwc created
% 7 may 07  fwc runs at maxpriority, added waitsecs call, hopefully solves
%                   problems of missing triggers.
% adapted to videoRecord4Presentation

commandwindow;

devices=GetKeyboardIndices;
if length(devices) < 2
    warndlg('Only single keyboard found', 'No trigger device warning');
end

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


% stuff for videorecording
videoRecMode=2; % 0== rec off, 1==rec on, 2= dummymode
recmoviedir='movierecords';
logVideoFrameMode='logFramesOff'; % 'logFramesOff;
movieRecStartTime=0;

% subject='jantje';
% session=1;

waitTime=0.001; % time to wait once we've received a trigger


maxWait=6000;

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
nextKey=KbName(keyNames.nextKey);
triggerKey=KbName(keyNames.triggerKey);
leftwardKey=KbName(keyNames.leftwardKey);
rightwardKey=KbName(keyNames.rightwardKey);


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


% here we open a window and paint it gray
[window, winrect]=Screen('OpenWindow',screenNumber);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
Screen('FillRect',window, gray);
Screen('Flip', window);
Screen('FillRect',window, gray);
Screen('Flip', window,[],2);
monitorRefreshInterval =Screen('GetFlipInterval', window);
frameRate=Screen('FrameRate',screenNumber);
if(frameRate==0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
    frameRate=60; % good assumption for most labtopss/LCD screens
end

Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1);



if videoRecMode>0
    % tell recorder where to save movie files
    % we can create a new dir for each subject
    mvdir=[recmoviedir filesep subject]; %
    VideoRecorder('moviedir', mvdir);
    % tell recorder to save to which movie file
    % each session can have its own movie file
    % this will also open log file, so we can write some messages
    moviename=[subject '_session' num2str(session) ]; %
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
    VideoRecorder( 'DisplayOn' );

    VideoRecorder('message', ['Subject: ' subject ] );
    VideoRecorder('message', ['Session: ' num2str(session) ] );
    %     VideoRecorder('message', ['Par file: ' myparfile ] );
end



WaitSecs(1);



% start video recording
if videoRecMode>0
    disp('start video recording');
    VideoRecorder('startrecording'); % start grabbing
    movieRecStartTime=GetSecs;
    VideoRecorder('message', ['MovieRecStartTime: ' sprintf('%.2f', movieRecStartTime ) ] );
end

[trigger triggerTime goOn]=CheckForTrigger(devices, triggerKey, quitKey, -1); % just so that we have used it
[mx, my, buttons]=GetMouse(window);

np=MaxPriority(max(Screen('Screens')));
op=Priority(np);

WaitSecs(1);


% goOn=WaitForScanner(window, keyNames);
VideoRecorder('message', ['Wait for scanner'] );
VideoRecorder('message', sprintf('MovieTriggerTime\tExpTriggerTime\tTriggerInterval'));

delta=0;
frameCount=1;
pts=0;
TR=2.5;
prevTriggerTime=-1;
nextTriggerDelay=TR-0.5;
firstTriggerReceived=0;
checkTime=movieRecStartTime;
while 1


    % wait for trigger, when stimulus is ready

    [trigger triggerTime goOn]=CheckForTrigger(devices, triggerKey, quitKey, checkTime);
    if goOn==0
        display('User requested break');
        break
    end

    if trigger>0
        disp('Trigger received');
        checkTime=triggerTime+nextTriggerDelay; % time to check for next trigger

        if firstTriggerReceived==0
            firstTriggerTime=triggerTime;
            prevTriggerTime=triggerTime;
            firstTriggerReceived=1;
            expTT=0;
            deltaTT=0;
        else
            expTT=triggerTime-firstTriggerTime;
        end

        if prevTriggerTime<triggerTime
            deltaTT=triggerTime-prevTriggerTime;
            prevTriggerTime=triggerTime;
        end

        tt=triggerTime-movieRecStartTime; % triggertime relative to moviestart
        VideoRecorder('message', sprintf('%.2f\t%.2f\t%.2f\t', tt, expTT, deltaTT ));

        Screen('FillRect', window, gray, [0 0 h 40]);
        DrawFormattedTextOnPoint(window, ['Tt: ' sprintf('%.2f', tt)], 400, 20, white, 'center', 'center');

        doFlip=1;
    end

    [status tex ts]=VideoRecorder('getframe');
    %     [status tex ts]=VideoRecorder('gettimestampnoblock');

    if tex>0
        frameCount=frameCount+1;
        %         Screen('DrawTexture', window, tex, [], [], 0, 0);
        %         Screen('Close', tex);
        %         tex=0;
        Screen('FillRect', window, gray, [0 v-50 h v]);
        if frameCount>1
          delta=ts-pts;
            DrawFormattedTextOnPoint(window, ['Dt: ' sprintf('%d', round(delta*1000))], 400, v-40, white, 'center', 'center');
        pts=ts;
            doFlip=1;
        end
    end
    if doFlip==1
        Screen('Flip', window, [], 2);
        doFlip=0;
    end



    WaitSecs(waitTime);
end

VideoRecorder('message', 'experiment end');

disp('stop recording');
VideoRecorder('stoprecording');
Priority(op);

Screen('CloseAll');




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

function [t tt goOn]=CheckForTrigger(devices, triggerKey, quitKey, checkTime)

% wait for trigger from scanner
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment.
% we only check for a trigger when checkTime has passed,
% to avoid multiple detections of the same trigger


goOn=1; % do not continue with experiment
tt=-1;
t=-1;
%
if GetSecs > checkTime
    % wait for key press
    [keyIsDown,tt,keyCode] = KbCheckAny(devices);

    % check if a key was pressed
    if keyIsDown==1
        % test if the user wanted to stop
        if keyCode(quitKey)
            goOn=0;
            %             display('User requested break');
            return
        elseif keyCode(triggerKey)
            %             display('Trigger received');
            goOn=1; % okidoki
            t=1;
            return
        end
    end
end


%
% function goOn=WaitForTrigger(maxWait, keyNames)
%
% % wait for trigger from scanner
% % keyNames is a structure containing relevant keys
% % function returns a parameter indicating whether or not to go on
% % with the experiment.
%
% goOn=0; % do not continue with experiment
%
%
% % wait for key release
% while KbCheck
%     WaitSecs(0.001);
% end
%
% quitKey=KbName(keyNames.quitKey);
% triggerKey=KbName(keyNames.triggerKey);
%
% endWait=GetSecs+maxWait;
% % wait for key press
% while GetSecs<endWait
%     [keyIsDown,secs,keyCode] = KbCheck;
%
%     % check if a key was pressed
%     if keyIsDown==1
%         % test if the user wanted to stop
%         if keyCode(quitKey)
%             display('User requested break');
%             break;
%         elseif keyCode(triggerKey)
%             goOn=1; % okidoki
%             break;
%         end
%     end
%     WaitSecs(0.001);
% end
%
%
%

function goOn=WaitForScanner(window, keyNames)

% wait for scanner
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment. Screen is erased before returning.

goOn=1; % do not continue with experiment

tstring='Waiting for scanner';

% tstring=[tstring '\n\n\n\n'];
% tstring=[tstring 'Press the ''' keyNames.triggerKey ''' key to advance\n'];
% tstring=[tstring 'Press the ''' keyNames.quitKey ''' key to abort,\n'];


Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 1);


DrawFormattedTextOnPoint(window, tstring, 400, 20, WhiteIndex(window), 'center', 'center');
Screen('Flip', window, [], 2);

