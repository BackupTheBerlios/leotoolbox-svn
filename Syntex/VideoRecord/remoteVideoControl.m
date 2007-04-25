function status=remoteVideoControl(command, varargin)
% attempt to make remote control for matlab video recording program

status=1;
persistent rmv;
persistent remoteip;

switch(lower(command))
    case {'recorder', 'remoteip', 'device', 'computer'},
        remoteip=varargin{1};

    case {'init', 'on', 'switchon'},
        if length(varargin)==1 && ~isempty(varargin{1})
            remoteip=varargin{1};
        end
        [status, rmv]=remoteVideo('init', [], remoteip);
    case 'message',
        message=['message' ' ' varargin{1}];
        status=remoteVideo('send', rmv, message);

    case {'start', 'startrecording'},
        % start recording on remote computer
        if isempty(rmv)
            status=0;
            return;
        end

        status=remoteVideo('send', rmv, 'start')
    case {'stop', 'stoprecording'},
        if isempty(rmv)
            status=0;
            return;
        end
        status=remoteVideo('send', rmv, 'stop');
    case {'shutdown', 'off', 'shutoff', 'switchoff'},
        if isempty(rmv)
            status=0;
            return;
        end
        status=remoteVideo('send', rmv, 'shutdown')
    case 'moviedir',
        message=['moviedir' ' ' varargin{1}];
        status=remoteVideo('send', rmv, message);
    case 'moviename',
        message=['moviename' ' ' varargin{1}];
        status=remoteVideo('send', rmv, message);
    case 'displayoff',
        % switch of live display (recording will continue)
        status=remoteVideo('send', rmv, 'displayoff');
    case 'displayon',
        % switch on live display again
        status=remoteVideo('send', rmv, 'displayon');
    otherwise,
        disp([mfilename ': unknown command: ' command]);
end

