function remoteVideoControl4Presentation % remote video control test
% it will send commands to another computer that, when it has
% the remoteVideoRecorder.m script running, will record video.
% also requires remoteVideo.m and remoteVideoControl.m scripts to be
% present

% History
% april 07  fwc created
% 7 may 07  fwc runs at maxpriority, added waitsecs call, hopefully solves
%                   problems of missing triggers.

commandwindow;

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


recorder='10.0.1.6'; % ip of remote video recording computer
recorder='Vulpes.local'; % it also works with 'computername.local'
% recorder='richard-jacobs-computer.local'; % it also works with 'computername.local'
recorder='localhost'; % it also works with 'computername.local'
recorder='richard-jacobs-computer.local'; % it also works with 'computername.local'
recorder='charmaine-pietersens-computer.local'; % it also works with 'computername.local'
moviedir='movies';
% subject='jantje';
% session=1;

waitTime=1; % time to wait once we've received a trigger


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
leftwardKey=KbName(keyNames.leftwardKey);
rightwardKey=KbName(keyNames.rightwardKey);


% select which computer we want to control
remoteVideoControl('recorder', recorder)

% switch remote control on
remoteVideoControl('switchon');

WaitSecs(1);

% tell recorder where to save movie files
% we can create a new dir for each subject

mvdir=[moviedir filesep subject]; % of course, this can be anything
remoteVideoControl('moviedir', mvdir);

% tell recorder to save to which movie file
% each session can have its own movie file
moviename=[subject '_session' num2str(session) '.mov' ]; % of course, this can be anything
remoteVideoControl('moviename', moviename);


disp('start recording');
remoteVideoControl('startrecording');

remoteVideoControl('message', ['subject: ' subject ]);
remoteVideoControl('message', ['session: ' num2str(session) ]);

np=MaxPriority(max(Screen('Screens')));
op=Priority(np);

WaitSecs(1);
firstTT=-1;
while 1
    disp(['Waiting for trigger']);
    goOn=WaitForTrigger(maxWait, keyNames);
    triggerTime=GetSecs;
    if firstTT<0
        firstTT=triggerTime;
        deltaTT=0;
    else
        deltaTT=triggerTime-firstTT;
    end
    remoteVideoControl('message', ['trigger time: ' num2str(triggerTime) ' delta: ' num2str(deltaTT)]);
    display('Trigger received');

    if goOn==0
        break
    end
    WaitSecs(waitTime);
end

remoteVideoControl('message', 'experiment end');

disp('stop recording');
remoteVideoControl('stoprecording');
Priority(op);

% WaitSecs(2);

% disp('shutdown recorder altogether');
% remoteVideoControl('shutdown');


function goOn=WaitForTrigger(maxWait, keyNames)

% wait for trigger from scanner
% keyNames is a structure containing relevant keys
% function returns a parameter indicating whether or not to go on
% with the experiment.

goOn=0; % do not continue with experiment


% wait for key release
while KbCheck
    WaitSecs(0.001);
end

quitKey=KbName(keyNames.quitKey);
triggerKey=KbName(keyNames.triggerKey);

endWait=GetSecs+maxWait;
% wait for key press
while GetSecs<endWait
    [keyIsDown,secs,keyCode] = KbCheck;

    % check if a key was pressed
    if keyIsDown==1
        % test if the user wanted to stop
        if keyCode(quitKey)
            display('User requested break');
            break;
        elseif keyCode(triggerKey)
            goOn=1; % okidoki
            break;
        end
    end
    WaitSecs(0.001);
end



