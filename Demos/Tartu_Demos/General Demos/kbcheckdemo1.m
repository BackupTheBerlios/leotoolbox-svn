% first key board demo
% also shows use of while and if /else statement
% find and KbName

clear all;
commandwindow;
nr=1000;
while nr>0

    [keyIsDown,secs,keyCode] = KbCheck();
       
    if keyIsDown==1
        display('Key Pressed');
        find(keyCode)
        KbName(find(keyCode))
    else
        display('No Key');
    end
    
    nr=nr-1;
    
    WaitSecs(.01);
end




% task: change message(s), make message change depending on key pressed