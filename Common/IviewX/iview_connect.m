function[socket] = iview_connect(host)
%
%  Opens a new UDP connection to the host
%  on port 4444

socket = pnet('udpsocket', 4444);

%host is send to check wether it is alive

try 
    pnet(socket, 'udpconnect', host, 4444);
catch
    e = ['Host (' host ') is dead, or no valid connection available'];
    error(e);
    socket = -1;
end;