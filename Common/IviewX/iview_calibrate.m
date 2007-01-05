function iview_calibrate(s, host)
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
	  operator_says = pnet(s,'read',1000,'char');
      assignin('base', 'op', operator_says);
      [command, parameters] = parse_iview_command(operator_says);
      parameters;
      end
      if (timed_out(timeout)) break; end;      
      if (user_aborted(s, operator_says)) break; end;      

    end
    
    if size(parameters) > 0
        number = parameters(1);
        fprintf('Starting calibration with %n points\n', number);
        iview_send(s, ['ET_CAL ' number], host);
    else
        fprintf('Parameters : %n', number);
        error('Incorrect number of calibration points found!');
        iview_send(s, 'ET_BRK', host);
    end;
    tic;
    fprintf('Awating screen size :\n');
    while ( strcmp(command,'ET_CSZ') == 0),
      % Wait/Read udp packet to read buffer
      len=pnet(s,'readpacket');
   
      if len>0,
	  % if packet larger then 1 byte then read maximum of 1000 doubles in network byte order
	    operator_says = pnet(s,'read',1000,'char');
        [command, parameters] = parse_iview_command(operator_says);            
        parameters
      end
      if (timed_out(timeout)) break;  end;     
      if (user_aborted(s, operator_says)) break; end;      
    end
    
    calibration.resolution = [parameters(1) parameters(2)];
    fprintf('Found calibration resolution : %n x %n \n', parameters(1), parameters(2));
    iview_send(s, ['ET_CSZ ' num2str(parameters(1)) '\t' num2str(parameters(2))], host);

    P = 1:number;
    
    
  while( number ~= 0),
      len = pnet(s, 'readpacket');
      if len > 0,
         operator_says = pnet(s, 'read', 1000,'char');
         [command, parameters] = parse_iview_command(operator_says);           
         
         if (strcmp(command,'ET_PNT') ),               
            n = parameters(1);
            index = find(P == n);
            if (index > 0)
               
               calibration_point(n).number = n;
               calibration_point(n).x = parameters(2);
               calibration_point(n).y = parameters(3);
               %fprintf('Found point %n at (x,y): (%n, %n) \n', number, parameters(2), parameters(3));
               P_acc = [ P(1:index-1) P(index+1:size(P,2)) ];    
               P = P_acc;
               number = number -1;
              %iview_iview_send(s, 'ET_CHG 2', host);
            end;
         end;
      end;
      if (timed_out(timeout)) break;  end;     
      if (user_aborted(s, operator_says)) break; end;      

  end;    

  calibration.points = calibration_point;
  assignin('base', 'calibration', calibration);
end;



screens = build_calibration_screens(calibration);
assignin('base', 'screens', screens);
iview_send(s, 'ET_ACC\n', host);

%
% O:ET_PNT 9
% O:ET_CHG1
% S: ET_ACC
% O: ET_ACC
% O: ET_CHG 7
% O: ET_ACC
% O: ET_CHG x
% O: ET_ACC
%
%
%
%
while(strcmp(command, 'ET_FIN') == 0)
      len = pnet(s, 'readpacket');
      if len > 0,
         operator_says = pnet(s, 'read', 1000,'char')
         [command, parameters] = parse_iview_command(operator_says) 
         
         if (strcmp(command, 'ET_CHG'))
            
             number = parameters(1)
             present(screens(number));
             iview_send(s, 'ET_ACC\n', host);
         end;
        
         while(strcmp(command, 'ET_ACC') == 0),
             
         end;
      end;
      if (timed_out(timeout)) break;  end;     
      if (user_aborted(s, operator_says)) break; end;      

end
         
fprintf('Done calibrating\n');











function[result] = user_aborted(s, operator_says)
   [command, parameters] = parse_iview_command(operator_says) 
   if (strcmp(command, 'ET_BRK'))
      fprintf('User aborted\n');
      iview_close(s);
      result = 1;
   else
      result = 0;
   end;
      
function[result] = timed_out(timeout)
  time = toc;
  if (time > timeout)
      fprintf('Timeout occurred\n');
      result = 1;
  else
      result = 0;
  end;