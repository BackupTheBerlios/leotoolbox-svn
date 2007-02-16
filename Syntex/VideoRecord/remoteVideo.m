function [result, ivx]=remoteVideo(cstr, ivx, varargin)

% USAGE: [result, rmv]=remoteVideo(cstr, rmv [, varargin])
%
% remoteVideo requires as input:
% 1. a command string
% 2. a structure with default values (empty during initialization).
% ivx: structure holding default information
% varargin: optional parameters to pass on with the command
%
% returns:
% result: any result produced by the command
% ivx: structure with default information (that may have been modified)
%
% possible commands for use on the recorder computer:
% init: initialize settings, supply ip# and port
%       remoteip='10.0.1.2';
%       [status, rmv]=remoteVideo('init', [], remoteip);
%
%  open: open connection for remote control
%   [status, rmv]=remoteVideo('open', rmv);
% check: check whether connection is still live
%       [status, rmv]=remoteVideo('check', rmv);
% receive: check if a command has been send, if so, get it.
%       [commandstr, rmv]=remoteVideo('receive', rmv);
% shutdown: close connenction for remote control
%       [status, rmv]=remoteVideo('close', rmv);
%
%
% issue e.g. the following commands from the controlling computer
% start: start recording
%       status=remoteVideo('send', rmv, 'start')
% stop: stop recording
%       status=remoteVideo('send', rmv, 'stop')
% (availability of (other) commands is  depending on the implementation of the
% recorder program!

% History
% 15.02.2007  fwc first version, based on iviewx function
% 16.02.2007  fwc             added bit of comments

result=-1;

if ~exist('cstr', 'var') || isempty(cstr)
    disp([ mfilename ' requires a command string as first input.']);
    help remoteVideo
    return
end

switch lower(cstr)
    case {'help', '?'},
        help remoteVideo
        return
end

if strcmpi(cstr, 'init')~=1 && (~exist('ivx', 'var') || isempty(ivx))
    txt=[ mfilename ' requires a structure with default values as second input.'];
    error(txt);
end

switch lower(cstr)
    case 'init',
        pnet('closeall'); % close any open connections??
        ivx=[];
        if length(varargin)<1 || isempty(varargin{1})
            ivx.host='localhost';
%             ivx.host='192.168.1.2';
               % ivx.host='10.0.1.4';
        else
            ivx.host=varargin{1};
        end
        
        if length(varargin)<2 || isempty(varargin{2})
            ivx.port=3333;
        else
            ivx.port=varargin{2};
        end

        ivx.isconnected=1;
        ivx.notconnected=0;
        ivx.udp=[];

        % defaults for udp communication
        ivx.socket=1111; % used when sending messages
        ivx.localport=3333; % for receiving messages
        ivx.udpreadtimeout=0.01; % time out for reading
        ivx.udpmaxread=100; % maximum number of elements to read in
        result=1;
    case 'open',
        if isempty(ivx.udp)
            % open (and close) udp connection for receiving data from remote computer
            % Open  udpsocket and bind udp port adress to it.
            ivx.udp=pnet('udpsocket',ivx.localport);
            pnet(ivx.udp,'setreadtimeout',ivx.udpreadtimeout);
            if ~isempty(ivx.udp)
                stat=pnet(ivx.udp,'status');
                if stat>0
                    result=ivx.isconnected;
                end
            end
        end
    case 'close',
        if ~isempty(ivx.udp)
            pnet(ivx.udp,'close');
            ivx.udp=[];
        end
        result=1;
    case 'check',
        if ~isempty(ivx.udp)
            stat=pnet(ivx.udp,'status');
            if stat>0
                result=ivx.isconnected;
            end
        end
    case 'receive',
        if ~isempty(ivx.udp)
            % should we instead check status?
            % stat=pnet(ivx.udp,'status');

            % Wait/Read udp packet to read buffer
            len=pnet(ivx.udp,'readpacket');
            %len=pnet(udp,'readpacket',[],'noblock');
            % if len>0 fprintf('Len: %d\n', len); end

            if len>0,
                %   [ip,port]=pnet(ivx.udp,'gethost');
                % if packet larger then 1 byte then read maximum of 1000 doubles in network byte order
                %  data=pnet(udp,'read',ivx.udpmaxread,'double');
                result=pnet(ivx.udp,'read',ivx.udpmaxread);
            end
        end
    case 'send',
        % open udp connection, and send command string
        % if this is too time consuming, we should open a port and keep it open
        % for the time of the experiment
        % code modified after  udp_send_demo.m

        if ~isempty(varargin)
            sendstr=varargin{1}

            udp=pnet('udpsocket',ivx.socket);
            if udp~=-1,
                try, % Failsafe
                    pnet(udp,'udpconnect',ivx.host,ivx.port);
                    %         [ip,port]=pnet(udp,'gethost')
                    %         stat=pnet(udp,'status')
                    pnet(udp,'write',[sendstr char(10)]);        % Write to write buffer
                    pnet(udp,'writepacket',ivx.host,ivx.port);   % Send buffer as UDP packet

                catch,
                    pnet('closeall');
                    disp(lasterr)
                end
                %     [ip,port]=pnet(udp,'gethost')
                %     stat=pnet(udp,'status')
                pnet(udp,'close');
                result=1;
            end
        else
            fprintf('%s: Nothing to send....\n', mfilename );
        end

    otherwise,

        fprintf('%s: unknown command ''%s''\n', mfilename, command );
end

