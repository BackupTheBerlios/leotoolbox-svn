% mouse demo

clear all;
commandwindow;

display('Press mouse button to quit');

while 1
    [x,y,buttons] = GetMouse;
    
    mystr=['x=' num2str(x) ', y=' num2str(y)];
    disp(mystr);
    
    WaitSecs(0.1);
    
    if any(buttons)
        break;
    end
end



% task: print something different depending on mouse coordinates