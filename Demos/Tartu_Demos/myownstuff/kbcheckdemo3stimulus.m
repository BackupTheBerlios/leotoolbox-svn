% second key board demo
% also shows use of while/break and if elseif statement
% shows how to wait for keyboard release
% shows how to measure RT

clear all;
commandwindow;
quitKey=KbName('ESCAPE');
leftKey=KbName('c');
rightKey=KbName('m');
notstop=1;
ts=GetSecs;

while notstop==1

    dl=randperm(3);
    WaitSecs(dl(1));
    disp('Press key now');

    ts=GetSecs;

    while 1


        [keyIsDown,secs,keyCode] = KbCheck;

        if keyCode(quitKey)
            display('User requested break');
            notstop=0;
            break;
        end

        if keyIsDown
            %         display('Key');
            if keyCode(leftKey)==1
                display('Left Response');
                t=secs-ts;
                break;
            elseif keyCode(rightKey)==1
                display('Right Response');
                t=secs-ts;
                break;
            end

        end

        WaitSecs(0.001);
    end

    while KbCheck; end

    disp(t)

end

%  task: team up, and create a **simple** flanker test
