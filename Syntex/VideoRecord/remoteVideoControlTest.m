% remote video control test
commandwindow;

recorder='10.0.1.6'; % ip of remote video recording computer
moviedir='movies';
movieduration=5;
nsubjects=2;
nsessions=2;

session_offset=6;

% select which computer we want to control
remoteVideoControl('recorder', recorder)

% switch remote control on
remoteVideoControl('switchon')

WaitSecs(3);

for i=1:nsubjects

    % tell recorder where to save movie files
    % we can create a new dir for each subject

    mvdir=[moviedir filesep 'subject' num2str(i)];
    remoteVideoControl('moviedir', mvdir);

    for j=session_offset:nsessions+session_offset
        
    % tell recorder to save to which movie file
    % each session can have its own movie file
        moviename=['subject' num2str(i) '_session' num2str(j)]
        remoteVideoControl('moviename', moviename);

        disp('start recording')
        remoteVideoControl('startrecording');
        
        WaitSecs(1);
        
         remoteVideoControl('message', 'start trial');
        
        WaitSecs(movieduration);
        
         remoteVideoControl('message', 'halfway through the movie');
       
        WaitSecs(movieduration);
       
          remoteVideoControl('message', 'end off trial');
 
          WaitSecs(1);
 
        disp('stop recording')
        remoteVideoControl('stoprecording');

        WaitSecs(4);

    end
end

disp('shutdown recorder altogether');
remoteVideoControl('shutdown');
