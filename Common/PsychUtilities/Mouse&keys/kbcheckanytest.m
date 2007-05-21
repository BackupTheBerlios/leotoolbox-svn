commandwindow
devices=GetKeyboardIndices;

devices
disp('start');
ts=GetSecs;
while GetSecs< ts+20
    [keyIsDown,secs, keyCode] = KbCheckAny(devices);
    if keyIsDown
%         keyIsDown
        disp(['Pressed: ' KbName(find(keyCode))]);
    end
end
disp('done');