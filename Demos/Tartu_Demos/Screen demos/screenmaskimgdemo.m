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
    [w, wrect]=Screen('OpenWindow',screenNumber);
    
    % enable alpha blending
    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    Screen('FillRect',w, gray);
    Screen('Flip', w);

    
    % We create a Luminance+Alpha matrix for use as transparency mask:
    ms=200;
    transLayer=2;
    [x,y]=meshgrid(-ms:ms, -ms:ms);
    xsd=ms/2.0;
    ysd=ms/2.0;
    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.

    mask=uint8(ones(2*ms+1, 2*ms+1, transLayer) * gray);    
    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    mask(:,:,transLayer)=uint8(round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255));
    masktex=Screen('MakeTexture', w, mask);
    mrect=Screen('Rect', masktex);

    
    myimg='konijntjes1024x768.jpg';
    imdata=imread(myimg);
    imtex=Screen('MakeTexture', w, imdata);
    rect=CenterRectInWindow(wrect/2, w);
    Screen('DrawTexture', w, imtex, [], rect); % draw image
    Screen('DrawTexture', w, masktex); % draw and alpha blend with image
    
    if 1 % set to 1 to display short text message on screen
        Screen('TextFont',w, 'Times');
        Screen('TextSize',w, 100);
%         Screen('TextStyle', w, 0);
        Screen('DrawText', w, 'Masked Rabbit', [], [], white);
    end
    
    Screen('Flip', w);

    
    
    WaitSecs(2);

    %The same commands which close onscreen and offscreen windows also close
    %textures.
    Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    rethrow(lasterror);
end %try..catch..




% task: make mask cover whole image, invert mask
% task: make image move over screen, make it move with mouse


