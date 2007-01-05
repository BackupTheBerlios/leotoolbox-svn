function[result] = iview_send(socket,  command, host )

try,
    pnet(socket, 'write', command);
    result = pnet(socket, 'writepacket', host, 4444);
end;
