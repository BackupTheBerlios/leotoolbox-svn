commandwindow;
clc;
disp('start');

hit=0;
while hit==0
    hit=KbCheck(5);
    WaitSecs(0.001);
end
disp('hit');
