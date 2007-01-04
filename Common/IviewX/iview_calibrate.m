function iview_calibrate(s)
  host = '192.168.10.165';
  command = '';
  parameters = [];
  calibration = struct('resolution', [], 'points', []);
  calibration_point = struct('number', 0,'x',0 , 'y', 0);
  
  calibration.resolution = [0 0];
  timeout = 10;
  
  pnet(s,'setreadtimeout',timeout)
  if s ~= -1,
    len = 0; 
    tic;
    while ( strcmp(command, 'ET_CAL') == 0),
      % Wait/Read udp packet to read buffer
      len=pnet(s,'readpacket');
      if len>0,
	  % if packet larger then 1 byte then read maximum of 1000 doubles in network byte order
	  operator_says = pnet(s,'read',1000,'char')
      [command, parameters] = parse_iview_command(operator_says);
      parameters;
      end
      if (timed_out(timeout)) break; end;

    end
    if size(parameters) > 0
        number = str2num(parameters(1));
        fprintf('Starting calibration with %s points\n', number);
    else
        
        error('Incorrect number of calibration points found!');
    end;
    tic;
    fprintf('Awating screen size :\n');
    while ( strcmp(command,'ET_CSZ') == 0),
      % Wait/Read udp packet to read buffer
      len=pnet(s,'readpacket');
   
      if len>0,
	  % if packet larger then 1 byte then read maximum of 1000 doubles in network byte order
	    operator_says = pnet(s,'read',1000,'char');
        assignin('base', 'op', operator_says);
        [command, parameters] = parse_iview_command(operator_says);            
        parameters
      end
      if (timed_out(timeout)) break;  end;     

    end
    calibration.resolution = [str2num(parameters(1)) str2num(parameters(2))];
    fprintf('Found calibration resolution : %i x %i\n', str2num(parameters(1)), str2num(parameters(2)));
    
    for P = 1:number,
      tic;
      while( strcmp(command, 'ET_PNT') == 0 && (parameters(1) ~= P) ),
          len = pnet(s, 'readpacket');
          if len > 0,
              operator_says = pnet(s, 'read', 1000,'char');
              [command, parameters] = parse_iview_command(operator_says);
          end;
      if (timed_out(timeout)) break; end;
      end; 
      calibration_point(P).number = P;
      calibration_point(P).x = parameters(2);
      calibration_point(P).y = parameters(3);
      fprintf('Found point %d at (x,y): (%s, %s)\n', P, parameters(2), parameters(3));
  end;
    
  calibration.points = calibration_point;
  assignin('base', 'calibration', calibration);
 else iview_close(s);
end;

function[result] = timed_out(timeout)
  time = toc;
  if (time > timeout)
      fprintf('Timeout occurred\n');
      result = 1;
  else
      result = 0;
  end;