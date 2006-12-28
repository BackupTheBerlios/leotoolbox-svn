try
    fprintf('AlphaImageDemo (%s)\n click on key or mouse to stop\n', datestr(now));

    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    % Get the list of screens and choose the one with the highest screen number.
    % Screen 0 is, by definition, the display with the menu bar. Often when
    % two monitors are connected the one without the menu bar is used as
    % the stimulus display.  Chosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.

    screenNumber=max(Screen('Screens'));

    % Open a double buffered fullscreen window and draw a gray background
    % and front and back buffers.
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Find the color values which correspond to white and black.  Though on OS
    % X we currently only support true color and thus, for scalar color
    % arguments,
    % black is always 0 and white 255, this rule is not true on other platforms will
    % not remain true on OS X after we add other color depth modes.
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen

    

    
    Screen('FillRect',w, gray);
    Screen('Flip', w);

    [a,b]=WindowCenter(w);
    [h,v]=WindowSize(w);
    
    WaitSetMouse(a,b,w); % set cursor and wait for it to take effect   
    
    outer=[ 0 0 v v];
    outer=InsetRect(outer, 150, 150);
    outer=CenterRect(outer, wRect);
    annulus=outer;
    
    annuluswidth=25;
    ringwidth=50;
    
    inner=outer;
    inner=InsetRect(inner, annuluswidth, annuluswidth);
    inner=CenterRect(inner, outer);
    
    annulus2=InsetRect(inner, ringwidth, ringwidth);
    inner2=InsetRect(annulus2, annuluswidth, annuluswidth);
 
    
    
    HideCursor;
    buttons=0;

    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    k=0.5;
    period=2;
    
    while KbCheck; WaitSecs(0.1); end;
    Screen('Flip', w); % would be useful 
    mxold=0;
    myold=0;
    
    tStart=GetSecs;
    
    while 1        
        % We wait at least 10 ms each loop-iteration so that we
        % don't overload the system in realtime-priority:
        WaitSecs(0.01);
        
        [mx, my, buttons]=GetMouse(w);

        % We only redraw if mouse has been moved:
%         if (mx~=mxold | my~=myold)            
%             myrect=[mx-ms my-ms mx+ms+1 my+ms+1]; % center dRect on current mouseposition
%             dRect = ClipRect(myrect,ctRect);
%             sRect=OffsetRect(dRect, -dx, -dy);
% 
%             if ~IsEmptyRect(dRect)
%                 % Draw image for current frame:
%                 % Overdraw -- and therefore alpha-blend -- with gaussian alpha mask:
%                 % Show result on screen:
%                 Screen('Flip', w);
%             end
%         end;
        
        
        outcolor=black;
        disccolor=gray;
%         disccolor=64;
        annuluscolor=gray;
        annuluscolor=white;
       
        m=k*sin(((Getsecs-tStart)/period)*2*pi);
        
        outcolor=gray+m*min((white-gray),(gray-black));
        
        Screen('FillRect',w, outcolor);
        Screen('FillOval',w, annuluscolor, annulus);
        Screen('FillOval',w, disccolor, inner);
        Screen('FillOval',w, annuluscolor, annulus2);
        Screen('FillOval',w, outcolor, inner2);
        Screen('Flip', w);

        mxold=mx;
        myold=my;

        if KbCheck | find(buttons) % break out of loop
            break;
        end;
    end;
    Screen('FillRect',w, gray);
    Screen('Flip', w);


    
    
    
    %The same commands which closes onscreen and offscreen windows also
    %closes textures.
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fprintf('End of AlphaImageDemo\n\n');

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    rethrow(lasterror);
    commandwindow; % moves commandwindow up front, handy in case of a break.
end %try..catch..

