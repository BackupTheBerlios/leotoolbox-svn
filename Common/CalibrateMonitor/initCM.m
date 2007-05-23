function [par connFail] = initCM(par)

if par.cm.port ~= 0 % give it a zero for simulation
    
    fprintf('Initialising Minolta Color Meter\n');
    
    SerialComm('open', par.cm.port,par.cm.portString);
    
    WaitSecs(par.cm.gwait);
    
    % do a test measurement to check the connection
    
    SerialComm('write', par.cm.port, ['MES', 13, 10, 0]);
    
    buffer = '';
    
    connFail = 0;
    
    tic
    
    while isempty(strfind(buffer,'OK')) %| connFail == 0
        
         buffer = SerialComm('readl', par.cm.port);
         isempty(strfind(buffer, 'OK'));
         timePassed = toc;
         
         if timePassed > par.cm.connCheckTime
             
             fprintf('Unable to connect succesfully with the color meter\n');
             fprintf('Please check the connection\n');
             connFail = 1;
             return
             % par.cm.port = -1;
             
         end
       
    end
    
    if ~isempty(strfind(buffer, 'OK'))
        
        fprintf('Succesfully checked the connection');
        
    end
        
else 
    
    fprintf('Initialising in simulation mode\n');
    
end
    