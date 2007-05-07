% remote video control test
% it will send commands to another computer that, when it has
% the remoteVideoRecorder.m script running, will record video.
% also requires remoteVideo.m and remoteVideoControl.m scripts to be
% present

commandwindow;

recorder='10.0.1.6'; % ip of remote video recording computer
recorder='Vulpes.local'; % it also works with 'computername.local'
% recorder='richard-jacobs-computer.local'; % it also works with 'computername.local'
moviedir='movies';
movieduration=10;
nsubjects=2;
nsessions=2;

session_offset=0;

% select which computer we want to control
remoteVideoControl('recorder', recorder)

% switch remote control on
remoteVideoControl('switchon')

WaitSecs(3);

for i=1:nsubjects

    % tell recorder where to save movie files
    % we can create a new dir for each subject

    mvdir=[moviedir filesep 'subject' num2str(i)]; % of course, this can be anything
    remoteVideoControl('moviedir', mvdir);

    for j=session_offset:nsessions+session_offset

        % tell recorder to save to which movie file
        % each session can have its own movie file
        moviename=['subject' num2str(i) '_session' num2str(j)]; % of course, this can be anything
        remoteVideoControl('moviename', moviename);

        disp('start recording');
        remoteVideoControl('startrecording');

        WaitSecs(1);

        remoteVideoControl('message', 'start trial');

        WaitSecs(movieduration);

        remoteVideoControl('message', 'halfway through the movie');

        WaitSecs(movieduration);

        remoteVideoControl('message', 'end of trial');

        WaitSecs(1);

        disp('stop recording');
        remoteVideoControl('stoprecording');

        WaitSecs(4);

    end
end

disp('shutdown recorder altogether');
remoteVideoControl('shutdown');
