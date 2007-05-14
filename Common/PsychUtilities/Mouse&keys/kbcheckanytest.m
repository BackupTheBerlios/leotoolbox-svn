commandwindow
devices=GetKeyboardIndices;

devices

ts=GetSecs;
while GetSecs< ts+30
    [keyIsDown,secs, keyCode] = KbCheckAny(devices);
    if keyIsDown
%         keyIsDown
        disp(['Pressed: ' KbName(find(keyCode))]);
    end
end
