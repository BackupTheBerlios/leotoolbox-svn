commandwindow;
disp( 'Gamepad test');

numGamepads = Gamepad('GetNumGamepads')
if numGamepads<=0
    disp( 'No Gamepads found');

    return;
end
gamepadIndex=1;
numAxes = Gamepad('GetNumAxes', gamepadIndex)

if numAxes< 1
    disp( 'No Axis found');

    return;
end
numButtons = Gamepad('GetNumButtons', gamepadIndex)

while 1
    WaitSecs(.1);
    [x y mbs]=GetMouse;
    if ~any(mbs)
        break;
    end
end


while 1

    for i=1:numAxes
        axisState(i) = Gamepad('GetAxis', gamepadIndex, i)
    end


    for i=1:numButtons
        buttonState(i) = Gamepad('GetButton', gamepadIndex, i);
        if buttonState(i)>0
            disp(['Button ' num2str(i)]);
        end

    end


    [x y mbs]=GetMouse;
    if any(mbs)
        disp('Break on mouse');
        break;
    end
    WaitSecs(0.01);

end


