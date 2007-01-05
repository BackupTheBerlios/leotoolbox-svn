function[] = iview_start

  try
      iview_close(s);
      clear s;
  catch
  end;
  host = '192.168.10.165';
  
  s = iview_connect(host);
  assignin('base', 'socket', s);
  %try
      iview_calibrate(s, host);
      iview_close(s);
  %catch
  %    fprintf(lasterr);
  %    fprintf('\n');
  %    iview_close(s);
  %end;