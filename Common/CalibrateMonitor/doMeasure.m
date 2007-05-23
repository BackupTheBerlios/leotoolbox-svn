function [par] = doMeasure(par)

% ok, so what do we need to do?

% the basic thing is to show the stimulus

% open the window
[window winrect] = Screen('OpenWindow', par.screen.screenNumber, 0, []);

% set general properties
Screen(window, 'TextFont', 'Helvetica');
Screen(window, 'TextSize', par.screen.fontSize);

% calculate and draw the center rectangle
targetRect = [0 0 round(winrect(3)*(par.screen.sizeOfRect/100)) round(winrect(4)*(par.screen.sizeOfRect/100))];
targetRect = CenterRect(targetRect, winrect);

% calculate nr of trials
[nrTrials crap] = size(par.meas.RGB_vec);

% hide cursor
HideCursor

% Minolta aiming
Screen('FillRect', window, [0 0 0]); 
Screen('FillRect', window, [255 255 255], targetRect);
txt = 'Aim Minolta at central square; press a key when done';
Screen('DrawText', window, txt, 50, 50, par.screen.textColor);
Screen('Flip', window);

while 1
	[KeyIsDown Secs KeyCode] = KbCheck;
	if KeyIsDown
		break
	end
end

% Countdown
Screen('FillRect', window, par.screen.bgColor); 
Screen('TextSize', window, par.screen.fontSize);
for sec = 1:par.meas.timeToLeave
	if sec > 1
		Screen('DrawText', window, ['You have ' num2str(par.meas.timeToLeave - sec + 2) ' second(s) to leave the room'], 20, 20, par.screen.bgColor);
	end
	Screen('DrawText', window, ['You have ' num2str(par.meas.timeToLeave - sec + 1) ' second(s) to leave the room'], 20, 20, par.screen.textColor);
    Screen('Flip', window);
	WaitSecs(1)
end

Screen('FillRect', window, par.screen.bgColor);

par.meas.measurement_vec = [];
par.screen.fontSize = 15;
infoline = 'Previous measurement: none';
Screen('TextSize', window,par.screen.fontSize);
Screen('DrawText', window,infoline, 20, 20, par.screen.textColor);
fprintf(['Starting measurements (' num2str(nrTrials) ' in total)...\n']);

for measureNum = 1:nrTrials
	% show target
	Screen('FillRect', window, par.meas.RGB_vec(measureNum, :), targetRect);
    Screen('Flip', window);
    
    % better check for keyboard press to break from programm
    [KeyIsDown Secs KeyCode] = KbCheck;
    
    if KeyCode(par.keys.quit) == 1
        par.abort = 1;
        Screen('Close', window);
        ShowCursor
        return
    end
    
	WaitSecs(par.screen.screenSettleTime);
	
	% measure
	if par.meas.simulate ~= 1
        
        SerialComm('write', par.cm.port, ['MES', 13, 10, 0]); % write for measurement
        buffer = '';
        
        while isempty(strfind(buffer, 'OK'))
            
            buffer = SerialComm('readl', par.cm.port) % read measurement from port
        
          end
        WaitSecs(2);
		rr=1
        SerialComm('write', par.cm.port, ['CLE', 13, 10, 0]); % send clear memory command to speed things up
        ss=1
        % parse buffer
		commas = find(buffer == ',');
        if length(commas) > 0
            errcode = buffer(1:commas(1) - 1);		
            Y = str2num(buffer(commas(1) + 1:commas(2) - 1));
            x = str2num(buffer(commas(2) + 1:commas(3) - 1));
            y = str2num(buffer(commas(3) + 1:length(buffer)));
            Screen('DrawText', window, infoline, 20, 20, par.screen.bgColor);
            infoline = ['Previous measurement (' num2str(measureNum) '/' num2str(nrTrials) '): Y=' num2str(Y) ' x=' num2str(x) ' y=' num2str(y) '    (RGB=' num2str(par.meas.RGB_vec(measureNum,:)) ')'];
            Screen('DrawText', window, infoline, 20, 20, par.screen.textColor);
		
            % add to results vector
            par.meas.measurement_vec = [par.meas.measurement_vec; [Y x y]];
            
            % save the measurement vec every time as a backup
            measureVals = par.meas.measurement_vec;
            save lastRes.mat measureVals
        
        else
            fprintf('Parse error: %s\n', buffer);
        end
	else
		WaitSecs(1.5); % simulation
	end
end

Screen('Close', window);
ShowCursor