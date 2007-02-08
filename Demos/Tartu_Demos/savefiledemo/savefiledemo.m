% save file demo
% shows how to measure simple choice RT
% shows the basic organization of a simple experiment
% shows how to save measured RT to a tab delimited file.

% Tartu Matlab & PsychToolbox course, Januari 2007, Tartu, Estonia
% Frans W. Cornelissen email: f.w.cornelissen@rug.nl
%
% History
% 08-01-07  fwc created

clear all;
commandwindow;

% here we specify a number of experimental variables
subject='s1';
nrTrials=20;


% here we specify our response keys
KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
quitKey=KbName('ESCAPE');
leftKey=KbName('c');
rightKey=KbName('m');
go_on=1;

% here, we specify the filename, and we print the header of the output file
% we immediately close the file again. Note that we are not checking whether
% the file already exists, so we may overwrite existing data!

myfile=[subject '_rtdata' '.txt']; % create a meaningful name
fp=fopen(myfile, 'w');
fprintf(fp, 'SUBJECT\tDATETIME\tTRIAL\tDELAY\tINSTR\tKEY\tRT\n');
fclose(fp);


% determine order of stimulus display
% half the trials we will show left, on other half right stimuli
stimType=randperm(nrTrials);
stimTypeCutOff=round(nrTrials/2);

% here, we print a short instruction for the subject

disp('Welcome to this simple reaction time experiment');
disp('Press the left or right key depending on the instruction');

% this is the start of the experimental loop
% consisting of stimulus display, response loop, and saving of response to
% a file
i=1; % initialize trial number
while go_on==1 & i<=nrTrials

    % determine a random delay between .5 and 2 secs.
    dl=0.5+rand*1.5;
    WaitSecs(dl);

    % determine the instruction to show, as a kind of stimulus
    % log the stimulus for later saving
    if stimType(i)>stimTypeCutOff
        instr='right';
        disp('Press right key');
    else
        instr='left';
        disp('Press left key');
    end
    % time start of 'stimulus' display
    ts=GetSecs;

    % this is the start of the response loop
    while 1
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
            % otherwise test if one of the specifed response keys was pressed
            if keyCode(leftKey)==1
                display('Left Response');
                respkey='left';
                rt=secs-ts;
                break;
            elseif keyCode(rightKey)==1
                display('Right Response');
                respkey='right';
                rt=secs-ts;
                break;
            end
        end

        % return control to the OS for a short time, to keep it happy.
        % we may loose real-time priority if we do not. Make this time
        % shorter for more frequent sampling of keys
        WaitSecs(0.005);
    end

    % if we got an actual response, we now will save the data to a file
    % note that we now append ('a') to the file! We'll multiply the rt
    % and dl parameters by 1000 to get milliseconds. We immediately close the file
    % again (just in case). Note the different symbols used to print
    % out different types of parameters. %s for strings/letters, %d for 
    % integers (whole numbers), %f for floating point numbers (with something after comma/dot).
    if go_on==1
        fp=fopen(myfile, 'a');
        date=datestr(now, 'dd.mm.yyyy HH:MM:SS'); % also record date + timestamp of response
        fprintf(fp, '%s\t%s\t%d\t%.1f\t%s\t%s\t%.1f\n', subject, date, i, dl*1000, instr, respkey, rt*1000);
        fclose(fp);

        % after getting a response , we'll wait to make sure the subject
        % released the keys, before starting a new trial
        while keyIsDown==1
            keyIsDown=KbCheck;
            WaitSecs(0.005);
        end
    end


    % incraese the trial number
    i=i+1;
end

% display a message indicating that the experiment has finished
if go_on==1
    disp('The experiment is completed, thanks for participating!');
else
    % in case of a break, some other message might be more appropriate
    disp('Please contact the experiment leader immediately, thanks!');
end

%  tasks: save data files to a directory 'rtdata'
%   check whether you're not overwriting an existing file
%   make sure there is at least a certain amount of time between trials
%   (iti)
% print a more complete instruction
% create a more interesting experiment
