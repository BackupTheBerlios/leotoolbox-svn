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
remoteip='10.0.1.6';


[status, rmv]=remoteVideo('init', [], remoteip);


% list contents of rmv structure
rmv;

if status~=1
    disp('error initializing');
    return
end

message=['moviedir' 'movies/test/test1'];
status=remoteVideo('send', rmv, message);

message=['moviename' 'mijnfilmpje'];
status=remoteVideo('send', rmv, message);



WaitSecs(1);

% start recording on remote computer
status=remoteVideo('send', rmv, 'start')

if status~=1
    disp('error starting recording');
    return
end

WaitSecs(5);

message=['message' ' ' 'eerste keer'];
status=remoteVideo('send', rmv, 'message');

WaitSecs(2);

message=['message' ' ' 'nog een bericht'];
status=remoteVideo('send', rmv, 'message');

WaitSecs(2);

message=['message' ' ' 'weer wat aan de hand'];
status=remoteVideo('send', rmv, 'message');


% % switch of live display (recording will continue)
% status=remoteVideo('send', rmv, 'displayOff')
% 
% WaitSecs(3);
% 
% % switch on live display again
% 
% status=remoteVideo('send', rmv, 'displayOn')
% 
WaitSecs(5);

% stop recording
status=remoteVideo('send', rmv, 'stop')

WaitSecs(1);

% shut down videorecording application on 
% remote computer.
if 0
status=remoteVideo('send', rmv, 'shutdown')
end
disp( [ mfilename ' finished']);

