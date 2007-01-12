function[s, window, wRect, host] = iview_start

  try
      iview_close(s);
      clear s;
  catch
  end;
  host = '192.168.10.165';
  
  s = iview_connect(host);
  assignin('base', 'socket', s);
  %try
  % initialize Psychtoolbox calibration screen
  screennumber = max(Screen('Screens'));
  Screen('Preference','SkipSyncTests',1)
  [window, wRect] = Screen('OpenWindow', screennumber);
  
  startscreen = picture;
  startscreen = add(startscreen, 'text', 'Calibration Instructions: Follow the crosses with your eyes.');
  present(startscreen, window, wRect, -1);
  
  %iview_calibrate(s, host, window, wRect);
  %iview_validate(s, host, window, wRect);
       
  %catch
  %    fprintf(lasterr);
  %    fprintf('\n');
  %    iview_close(s);
  %end;
  