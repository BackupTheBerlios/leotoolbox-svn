commandwindow

targetKey = KbName('LeftGUI');
distrKey = KbName('Enter'); % for some reason I don't get RightGUI

disp('press both keys');

% first loop to make sure subject presses both keys
while 1
    [a,b,keyCode] = KbCheck;
    if keyCode(targetKey) & keyCode(distrKey)
        break
    end
end

disp('start trial');

% trial loop, abort when subject releases one of the keys
while 1
    [a,b,keyCode] = KbCheck;
    if 0==keyCode(targetKey)
        disp('target');
        break
    end
    if 0==keyCode(distrKey)
        disp('distractor');
        break
    end

end

disp('done');