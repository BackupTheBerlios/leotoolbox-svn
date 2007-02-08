% second key board demo
% also shows use of while/break and if elseif statement
% shows how to wait for keyboard release

clear all;
commandwindow;
% ListenChar(2);
quitKey=KbName('ESCAPE');
leftKey=KbName('c');
rightKey=KbName('m');
ts=GetSecs
while 1

    [keyIsDown,secs,keyCode] = KbCheck;

    if keyCode(quitKey)
        display('User requested break');
        break;
    end
    
    if keyIsDown
%         display('Key');
        if keyCode(leftKey)==1
            display('Left Response');
        elseif keyCode(rightKey)==1
            display('Right Response');
        end

        while KbCheck; end
    end

    WaitSecs(0.01);
end

% ListenChar(0);


%  task: find a way to measure reaction time
