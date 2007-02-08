% screen use demo
% shows how to open a window and draw a square on screen
% and use drawtexture to display content of array

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

    myimg='konijntjes1024x768.jpg';
    imdata=imread(myimg);
    tex=Screen('MakeTexture', w, imdata);
    rect=Screen('Rect', tex);
    rect=rect/2;
    if 0
        Screen('DrawTexture', w, tex, rect);
    else
        wrect=Screen('Rect', w);
        rect=CenterRect(rect, wrect);
        Screen('DrawTexture', w, tex, [], rect);
    end
    
    if 1 % set to 1 to display short text message on screen
        Screen('TextFont',w, 'Arial');
        Screen('TextSize',w, 100);
        Screen('TextStyle', w, 0);
        Screen('DrawText', w, 'Rabbit', [], [], white);
    end
    
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




% task: find ways to display image such that each image point occupies 2x2 or 3x3
% display pixels

% task: find ways to manipulate colors of image
% task: create program that displays a series of images
% task: center text on screen
% task: create program that measures rt to image (e.g. natural vs.
% man-made).
% alt task: create program that slowly builds up image, measures rt to image (e.g. natural vs.
% man-made).

