% second key board demo
% also shows use of while/break and if elseif statement
% shows how to wait for keyboard release
% shows how to measure RT

clear all;
commandwindow;
quitKey=KbName('ESCAPE');
leftKey=KbName('c');
rightKey=KbName('m');
ts=GetSecs;
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
                        t=secs-ts
        elseif keyCode(rightKey)==1
            display('Right Response');
                        t=secs-ts
        end

            while KbCheck; end
    end

    WaitSecs(0.01);
end




%  task: team up, and create a **simple** flanker test
