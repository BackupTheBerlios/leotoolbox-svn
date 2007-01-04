function[socket] = iview_connect()
%
%  Opens a new UDP connection to the host
%  on port 4444

socket = pnet('udpsocket', 4444);
