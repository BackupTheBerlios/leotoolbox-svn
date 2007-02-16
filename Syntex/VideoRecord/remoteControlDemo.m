function remoteControlDemo

% demo's remote control of imaginary videorecorder...
% simply displays commands being passed on.
commandwindow;

disp(['start ' mfilename]);

quitkey=KbName('ESCAPE');
modkey=KbName('LeftGUI');

[status, rmv]=remoteVideo('init');
if status~=1
    disp('error initializing');
    return
end

[status, rmv]=remoteVideo('open', rmv);

if status~=1
    disp('error opening connection');
    return
end
i=0;
pctime=GetSecs;
while 1
    i=i+1;

    [keyIsDown, secs, keyCode] = KbCheck();

    if 1==keyCode(quitkey) && 1==keyCode(modkey)
        break;
    end

    [status, rmv]=remoteVideo('check', rmv);

    if status~=1
        disp('no connection');
        return
    end


    [cstr, rmv]=remoteVideo('receive', rmv);
    if cstr==-1
        fprintf( '.');
        if mod(i,40)==0
            fprintf( '\n');
        end
        WaitSecs(0.01);
        cstr='no';
    else
        cstr=cstr(1:end-1);
        ctime=GetSecs; % commandtime
        fprintf( '\ncommand: %s (%d) delta: %.1f  ms\n', cstr, length(cstr), (ctime-pctime)*1000);
        pctime=ctime;
    end

    
    switch(lower(cstr))
        case 'start',
            disp([mfilename ': start recording (''' cstr ''')']);
        case 'stop',
            disp([mfilename ': stop recording (''' cstr ''')']);
        case 'no',
            % do nothing

        otherwise,
            disp([mfilename ': Unknown command: (''' cstr ''')']);
    end

end





[status, rmv]=remoteVideo('close', rmv);
if status~=1
    disp('error closing connection');
    return
end


disp(['end ' mfilename]);

