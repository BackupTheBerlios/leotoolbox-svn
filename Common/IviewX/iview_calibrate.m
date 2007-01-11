function iview_calibrate(s, host, window, wRect)
command = '';
parameters = [];
calibration = struct('resolution', [], 'points', []);
calibration_point = struct('number', 0,'x',0 , 'y', 0);
calibration.resolution = [0 0];
timeout = 10;
iview_send(s, 'ET_EST', host);
operator_says = '';
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
        
        if (user_aborted(s, operator_says)) break; end;
        if (timed_out(timeout)) break; end;

    end

    if size(parameters) > 0
        number = parameters(1);
        fprintf('Starting calibration with %n points\n', number);
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
                    P_acc = [ P(1:index-1) P(index+1:size(P,2)) ];
                    P = P_acc;
                    number = number -1;
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
iview_send(s, 'ET_ACC', host);


first_fixation_point = 1;
while(strcmp(command, 'ET_FIN') == 0)
    len = pnet(s, 'readpacket');
    if len > 0,
        operator_says = pnet(s, 'read', 1000,'char');
        [command, parameters] = parse_iview_command(operator_says);

        fprintf('Awaiting ET_CHG command!\n');
        if (strcmp(command, 'ET_CHG'))
            fprintf('Changing calibration point to:\n');
            number = parameters(1)
            present(screens(number), window, wRect, -1);
            if (first_fixation_point && number == 1)
                % pause for first fixation;
                pause;
                first_fixation_point = 0;
                iview_send(s, 'ET_ACC', host);
            else

                printed = 0;
                operator_says = pnet(s, 'read', 1000,'char');
                [command, parameters] = parse_iview_command(operator_says);
                while(strcmp(command, 'ET_ACC') == 0),
                    len = pnet(s, 'readpacket');
                    operator_says = pnet(s, 'read', 1000,'char');
                    [command, parameters] = parse_iview_command(operator_says);
                    if len > 0,
                        if (strcmp(command, 'ET_CHG'))
                            fprintf('Changing calibration point to:\n');
                            number = parameters(1)
                            present(screens(number), window, wRect, -1);
                        end;
                        if (strcmp(command, 'ET_FIN'))
                            fprintf('Done calibrating\n');
                            endscreen = picture;
                            endscreen = add(endscreen, 'text', 'Done calibrating', 'location', [0 0]);
                            present(endscreen, window, wRect, -1);
                            break;
                        end;
                    end;
                    if printed == false,
                        fprintf('Awaiting ET_ACC command, for next fixation point\n');
                        printed = 1;
                    end;
                end;

            end;
        end;
    end;

    %% if (timed_out(timeout)) break;  end;
    if (user_aborted(s, operator_says)) break; end;
end;

endscreen = picture;
endscreen = add(endscreen, 'text', 'Done calibrating', 'location', [0 0]);
present(endscreen, window, wRect, -1);





function[result] = user_aborted(s, operator_says)
result = 0;
%[command, parameters] = parse_iview_command(operator_says)
%operator_quits = strcmp(command, 'ET_BRK');
%user_quits = (user_input == 'a');

%if (operator_quits)
%    fprintf('Calibration script aborted by operator.\n');
%    iview_close(s);
%    result = 1;
%end

%if (user_quits)
%    fprintf('Calibration script aborted by user.\n');
%    iview_close(s);
%    result = 1;
%end

%result = 0;


function[result] = timed_out(timeout)
time = toc;
if (time > timeout)
    fprintf('Timeout occurred\n');
    result = 1;
else
    result = 0;
end;