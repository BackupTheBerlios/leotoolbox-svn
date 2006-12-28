
function stroop

% 11/11/04 fwc simple demo based on question posted on ptb mailinglist.
% 281206    fwc some changes
clear all;
commandwindow;
try
    fprintf('\n***********************\n%s, press any key to quit\n***********************\n\n', mfilename);

    waitTime=0.5;
    screenNumber=max(Screen('Screens'));

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);
    red=[255 0 0];
    green=[0 255 0];
    % Open a double buffered fullscreen window and draw a gray background
    % and front and back buffers.

    HideCursor;
    [w, screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2);
    rect=CenterRect(screenRect/4, screenRect);
    
    
    Screen('TextFont',w, 'Courier');
    Screen('TextSize',w, 50);
    Screen('TextStyle', w, 0);

    Screen('FillRect',w, gray);
    Screen('Flip', w);

    r=InsetRect(screenRect,200,100);
    
    while KbCheck; end
    while 1
        
       Screen('FillRect',w, gray);
              
       x = randint(r(RectLeft), r(RectRight)); % function randint can be found below
       y = randint(r(RectTop) , r(RectBottom));
      
       if randint(1,2)==1
           mycolour=red;
       else
           mycolour=green;
       end
       
       if randint(1,2)==1
           mytext='red';
       else
           mytext='green';
       end

       
       Screen('DrawText', w, mytext, x, y, mycolour);

       Screen('Flip', w); % show on screen
       tEnd=GetSecs+waitTime; % show text for limited time
     
       while ~KbCheck & GetSecs<tEnd end
   
       % erase screen
       Screen('FillRect',w, gray);
       Screen('Flip', w);
   
       tEnd=GetSecs+waitTime; % wait a bit
       while ~KbCheck & GetSecs<tEnd end
   
       if KbCheck
           break;
       end
       
    end
    
    ShowCursor;
    Screen('CloseAll');
    fprintf('\n***********************\nEnd of %s.\n***********************\n\n', mfilename);
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..

%--------------------------------------

function x=randint(x0,x1)

% return random integer in range x0-x1
% code suggested by Keith Schneider
x = floor((x1+1-x0)*rand)+x0;

