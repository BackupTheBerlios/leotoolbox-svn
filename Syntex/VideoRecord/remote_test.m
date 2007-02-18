% simple script showing how to issue
% commands to start and stop video recording on
% a remote computer.
% the function remoteVideo needs to be on the path,
% or in the same directory as this script

% History
% 16022007  fwc     created
% 

% bring command window to the front
commandwindow;
disp( [ mfilename ' start']);

% initialize some parameters
% make sure you provide the correct ip number for
% the computer that will serve as a recorder
% leave third parameter empty to record on 'localhost'
% (the same compuer, in this case you need to run two local
% copies of matlab). Possibly, this may also work
% with computername.local .

remoteip='10.0.1.2';
remoteip='10.0.1.4';


[status, rmv]=remoteVideo('init', [], remoteip);


% list contents of rmv structure
rmv;

if status~=1
    disp('error initializing');
    return
end

WaitSecs(3);

% start recording on remote computer
status=remoteVideo('send', rmv, 'start')

if status~=1
    disp('error starting recording');
    return
end

WaitSecs(20);

% switch of live display (recording will continue)
status=remoteVideo('send', rmv, 'displayOff')

WaitSecs(20);

% switch on live display again

status=remoteVideo('send', rmv, 'displayOn')

WaitSecs(10);

% stop recording
status=remoteVideo('send', rmv, 'stop')

WaitSecs(3);

% shut down videorecording application on 
% remote computer.

status=remoteVideo('send', rmv, 'shutdown')

disp( [ mfilename ' finished']);

