function[s] = calibrate
clear all;


if 1
    [s, window, wRect, host] = iview_start;
    iview_calibrate(s, host, window, wRect);
    
else

    screennumber = max(Screen('Screens'));
    Screen('Preference','SkipSyncTests', 0);
    [window, wRect] = Screen('OpenWindow', screennumber);
    ivx = iViewXinitDefaults;
    ivx.host = '192.168.10.165';
    ivx.window = window;
    ivx.calPointOffset = [50 50];
    offset = [0 0];
    scale=[-70 -70];

    ivx = iViewXSetCalPoints(ivx, ivx.nCalPoints, offset, scale);
    print_points(ivx, window, wRect);
    
    fprintf('Connecting to :\t\t%s\n', ivx.host);
    fprintf('Socket :\t\t%d\n', ivx.port);
    fprintf('Presentation Screen:\t%d x %d\n', wRect(3), wRect(4));


   
    [success, ivx]=iViewX('calibrate', ivx);
end
    

%[s, window, wRect, host] = iview_start;
 
%iViewXCalibrate(ivx);
%iview_calibrate(s, host, window, wRect)

function[] = print_points(ivx, window, wRect)
  fprintf('Calibration Points :\n\n');
  
  for i = 1:ivx.nCalPoints
      fprintf('%d.\t [ %d x %d ]\n', i, ivx.absCalPos(i,1), ivx.absCalPos(i, 2));
  end

