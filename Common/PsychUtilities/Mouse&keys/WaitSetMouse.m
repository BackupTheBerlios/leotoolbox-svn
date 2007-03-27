function WaitSetMouse(newX, newY, windowPtrOrScreenNumber, maxWaitTime)

% set and wait for new cursor position to take effect
SetMouse(newX,newY,windowPtrOrScreenNumber);
if ~exist('maxWaitTime', 'var') || isempty(maxWaitTime)
    maxWaitTime=1; % default wait time
end
endTime=GetSecs+maxWaitTime;
while GetSecs<endTime % wait for new cursor position to be set, but not indefinetely
    [mx, my, buttons]=GetMouse(windowPtrOrScreenNumber);
    if mx==newX && my==newY
        break;
    end
end
