try
    commandwindow;
    AssertOpenGL;
    Waitsecs(0.5);
    
    if 1 Screen('Preference', 'SkipSyncTests', 1); end

    screens=Screen('Screens');
    screenNumber=max(screens);

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);
    
    [w, wRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    [ow,rect]=Screen('OpenOffscreenWindow',w, gray);

    
% parameter codes
    gap=1;
    xpos=2;
    ypos=3;
    size=4;
    
%     gap x y size
    
    item={
        'top', 100, 100, 25;
        'bottom', 200, 200, 50;
        'right', 300, 300, 100;
        'left', 400, 400, 150;
        'horizontal', 500, 600, 200;
        'top', 800, 100, 5;
        'bottom', 800, 200, 5;
        'right', 800, 300, 5;
        'left', 800, 400, 5;
        'vertical', 800, 600,200;
         'top', 800, 180, 3;
        'bottom', 700, 10, 50;
        'right', 600, 40, 100;
        'left', 500, 50, 60;
        'geen', 400, 60,30
   }
        
    Screen('FillRect', w ,gray);
    Screen('Flip', w);
    
    
    ts=GetSecs;
    for i=1:length(item)
        
      landoltC(w, item{i,xpos}, item{i,ypos}, item{i, size}, white, gray, item{i, gap});
      
    end
    te=GetSecs;
    
    Screen('Flip', w);

    fprintf('\nTekentijd: %.1f ms\n', (te-ts)*1000 );
    WaitSecs(6);








    Screen('CloseAll');
    fprintf('End of AFOV');
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..
