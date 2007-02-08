% first screen use demo
% shows how to open a window and draw a square on screen

try	
	% Get the list of screens and choose the one with the highest screen number.
	% Screen 0 is, by definition, the display with the menu bar. Often when 
	% two monitors are connected the one without the menu bar is used as 
	% the stimulus display.  Chosing the display with the highest dislay number is 
	% a best guess about where you want the stimulus displayed.  
	screens=Screen('Screens');
	screenNumber=max(screens);
	
    % Find the color values which correspond to white, black and gray.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true after we add other color depth modes.  
	white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
	gray=GrayIndex(screenNumber);
	
	% Open a double buffered fullscreen window and draw a gray background 
	% to front and back buffers:
% 	w=Screen('OpenWindow',screenNumber, 0,[],32,2);
	w=Screen('OpenWindow',screenNumber);
	Screen('FillRect',w, gray);
	Screen('Flip', w);
    
    rect=[0 0 200 200];
    color=[0 0 255];
	Screen('FillRect',w, color, rect);
    Screen('Flip', w);
%     Screen('Flip', w, [],1); % for not erasing square
    
    WaitSecs(1);
    rect=[400 400 600 600];
    color=[0 255 0];
	Screen('FillOval',w, color, rect);
    Screen('Flip', w);

    WaitSecs(2);
    
    %The same commands wich close onscreen and offscreen windows also close
	%textures.
	Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    rethrow(lasterror);
end %try..catch..





% task: modify to make square or oval move / change color / both


