function linetexturedisc(subject, session, parfile)


commandwindow;
home;
cd(FunctionFolder(mfilename));

dummymode=0;
diary([mfilename 'Log.txt']);

if 0
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

    if ~exist('parfile', 'var') || isempty(parfile)
        parfile=input('Parameter file (''filename'')? ');
        if isempty(parfile)
            disp('No parameter file given, experiment stopped');
            diary off;
            return;
        end
    end
end

try

    % here we read in information from the parameter file
    % using the autotextread function. It returns all information
    % in a structure that we call 'par'. The parameters themselves
    % are in fields (e.g. par.stimTime) called after whatever you named them in your
    % parameter file. If we get an error, we quit the experiment

    %     myparfiledir='parfiles';
    %     myparfile=[myparfiledir filesep parfile '.txt'] % construct parfile name
    %     par=autotextread(myparfile)

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

    % set linear gamma!!
    newGammaTable=repmat((linspace(0,1024,256)/1024)',1,3);
    oldGammaTable=Screen('LoadNormalizedGammaTable', screenNumber, newGammaTable);

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    % here we specify a number of important experimental variables
    % additional to those in the parameter file, but that are not
    % here we specify our response keys
    % keyNames is a structure containing relevant keys
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.leftwardKey='LeftArrow';
    keyNames.rightwardKey='RightArrow';

    keyNames.pauseKey{1}='LeftControl';
    %     keyNames.pauseKey{1}='space';
    keyNames.pauseKey{2}='LeftAlt';
    keyNames.pauseKey{3}='LeftGUI';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    leftwardKey=KbName(keyNames.leftwardKey);
    rightwardKey=KbName(keyNames.rightwardKey);

    % here, we specify the filename of the output file, and we print the header
    % we immediately close the file again. Note that we are not checking whether
    % the file already exists, so we may overwrite existing data!

    % here we open a window and paint it gray
    [window, winrect]=Screen('OpenWindow',screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',window, gray);
    Screen('Flip', window);
    monitorRefreshInterval =Screen('GetFlipInterval', window);
    frameRate=Screen('FrameRate',screenNumber);
    if(frameRate==0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
        frameRate=60; % good assumption for most labtops/LCD screens
    end

    [w h]=WindowSize(window);

    ndots=2000;
    rmax=round(h/2);
    r_in=round(rmax/2);
    ori=0; % base orientation
    d_ori=0; % maximum delta
    n_ori=0; % maximum noise
    colvect=white;
    svect=3;
    ll=7; % line length
    period=24;
    frames=10;

    r = rmax * sqrt(rand(ndots,1));	% r
    t = 2*pi*rand(ndots,1);                     % theta polar coordinate
    cs = [cos(t), sin(t)];
    xy = [r r] .* cs;   % line positions in Cartesian coordinates (pixels from center)
    l_in=find(r<r_in); % line positions in inner disk
    l_out=find(r>=r_in); % line positions in annulus

    [center(1), center(2)] = WindowCenter(window);

    ts=GetSecs;

    sl=1:2:ndots*2; % start positions in line xy matrix
    el=2:2:ndots*2; % end positions in line xy matrix
    xymatrix=zeros(2,ndots*2); % matrix of start and end points

    
    
    if ~exist('mask', 'var') || isempty(mask)
%         disp('calculating mask');
        % here, we determine the size of stimulus, and make a fitting mask
        % We create a Luminance+Alpha matrix for use as a transparency mask:

        msx=r_in;
        msy=msx; % should actually be equal by now

        [x,y]=meshgrid(-msx:msx, -msy:msy);
        % dist from center

        d=sqrt(x.^2+y.^2);
        pp=4; % 4 gives sharper edge
        dm=0; % center
        dsd=msx/1.5; % looks okay, empirically
%         mask=uint8(round(exp(-((d-dm)/dsd).^pp)*white));
        transLayer=2;
        mask=ones(2*msx+1, 2*msy+1, transLayer) * 0;

        mask(:,:,transLayer)=(d<r_in)*white;
%         mask(:,:,transLayer)=(d<r_in)*gray;
        max(max(mask));
        min(min(mask));
        
        masktex=Screen('MakeTexture', window, mask);
        maskRect=Screen('Rect', masktex);
        maskRect=CenterRect(maskRect, winrect);
    end

    if ~exist('mask2', 'var') || isempty(mask)
%         disp('calculating mask');
        % here, we determine the size of stimulus, and make a fitting mask
        % We create a Luminance+Alpha matrix for use as a transparency mask:

        msx=w/2;
        msy=msx; % should actually be equal by now

        [x,y]=meshgrid(-msx:msx, -msy:msy);
        % dist from center

        transLayer=2;
        mask2=ones(2*msx+1, 2*msy+1, transLayer) * gray;

        d=sqrt(x.^2+y.^2);
        mask2(:,:,transLayer)=(d>rmax-10)*white;
        
        masktex2=Screen('MakeTexture', window, mask2);
        maskRect2=Screen('Rect', masktex2);
        maskRect2=CenterRect(maskRect2, winrect);
    end
    
    osw=Screen('OpenOffscreenWindow', window, gray);
    Screen(osw,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
  
%         Screen('BlendFunction', w, GL_ONE, GL_ZERO);
%     Screen('FillRect', w, [128 128 128 0]); 

    td=GetSecs-ts;
    fprintf('preparation time: %.1f ms\n', td*1000);

    
    count=0;
    st_ori=zeros(10000,1);
    st_time=zeros(10000,1);

    Screen('Flip', window);
    tstart=GetSecs;
    tflip=tstart+0.050;

    while count<10000
        ts=GetSecs;
        count=count+1;
        
        % new random positions on every frame?
        if 1
            r = rmax * sqrt(rand(ndots,1));	% r
            t = 2*pi*rand(ndots,1);                     % theta polar coordinate
            cs = [cos(t), sin(t)];
            xy = [r r] .* cs;   % line positions in Cartesian coordinates (pixels from center)
            l_in=find(r<r_in); % line positions in inner disk
            l_out=find(r>=r_in); % line positions in annulus
        end

        cd_ori=d_ori(1)*(1+sin((GetSecs-tstart)/period*2*pi))/2;  % modulate current delta as a function of time
        st_ori(count)=cd_ori;

        if 1
            c_ori=rand(1,1)*2*ori; % randomize base orientation
        else
            c_ori=ori; % current base orientation
        end
        ori_in=(c_ori+cd_ori)*pi/180; % orientation of lines in disc
        ori_out=(c_ori-cd_ori)*pi/180; % orientation of lines in annulus

        o=ones(ndots,1); % init orientation vector
        o(l_in)=o(l_in)*ori_in;
        o(l_out)=o(l_out)*ori_out;
        no=rand(ndots,1)*n_ori*pi/180; % calculate orientation "noise" for each dot
        o=o+no; % add noise to signal

        % calculate displacement for start- and endpoint of lines
        dxdy=[cos(o)*ll sin(o)*ll];
        xymatrix(:, sl)=round(xy-dxdy)';
        xymatrix(:, el)=round(xy+dxdy)';
        tc=GetSecs-ts;
%         fprintf('Calculation time: %.1f ms\n', tc*1000);

        ts=GetSecs;

%         Screen('BlendFunction',osw,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
        Screen('FillOval', osw, gray );
%         Screen('FillRect', osw, [gray gray gray 255]);
        Screen('DrawLines', osw, xymatrix, svect, colvect, center,0);  % change 1 to 0 to draw non anti-aliased lines.
        td=GetSecs-ts;
%         fprintf('Line drawing time: %.1f ms\n', td*1000);

%         Screen('BlendFunction',window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
        Screen('BlendFunction', window, GL_ONE, GL_ZERO);
        Screen('FillRect', window, [gray gray gray 0]);
%         Screen('FillRect', window, [0 0 0 0]);

       if 1 
        % DRAW MASK
        Screen('BlendFunction', window, GL_ONE, GL_ONE);
%         Screen('BlendFunction', window, GL_ONE, GL_ZERO);
        Screen('DrawTexture', window, masktex, [], maskRect);

        % draw central disc
        Screen('BlendFunction', window, GL_DST_ALPHA, GL_ZERO);
%         Screen('BlendFunction', window, GL_DST_ALPHA, GL_ONE);
        Screen('DrawTexture', window, osw, [], [], -45);
        
        % Draw annulus
        Screen('BlendFunction', window, GL_ONE_MINUS_DST_ALPHA, GL_ONE);
%         Screen('BlendFunction', window, GL_ONE_MINUS_DST_ALPHA, GL_ZERO);
        Screen('DrawTexture', window, osw, [], [], 45);
  
        Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawTexture', window, masktex2, [], [], 0);

                
       end
  
        Screen('BlendFunction',window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
%         Screen('DrawTexture', window, masktex, [], maskRect);
        Screen('FillOval', window, white, CenterRect([0 0 10 10], winrect));
        Screen('DrawingFinished', window); % Tell PTB that no further drawing commands will follow before Screen('Flip')

        [dummy actFlipTime]=Screen('Flip', window, tflip);
        tflip=actFlipTime+(frames-.5)*monitorRefreshInterval;
        st_time(count)=GetSecs-tstart;
%         Waitsecs(0.003);
%     Screen('Close', osw);

        [x,y,buttons] = GetMouse;
        if any(buttons)
            break;
        end
    end
    Waitsecs(0.5);


    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);
    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    diary off

%     plot(st_time(1:count),st_ori(1:count));

    % This "catch" section executes in case of an error in the "try" section
    % above.  Importantly, it closes the onscreen window if it's open.

catch

    Screen('LoadNormalizedGammaTable', screenNumber, oldGammaTable);
    Screen('CloseAll');
    ShowCursor;

    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);

    psychrethrow(psychlasterror);
    diary off
end

