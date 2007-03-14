function WaitSetMouse(newX, newY, windowPtrOrScreenNumber)

% set and wait for new cursor position to take effect
SetMouse(newX,newY,windowPtrOrScreenNumber);

while 1 % wait for new cursor position to be set
    [mx, my, buttons]=GetMouse(windowPtrOrScreenNumber);
    if mx==newX && my==newY
        break;
    end
end
