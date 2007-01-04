function[result] = iview_send(socket,  command, host )

result = pnet(socket, 'write', command);
result = pnet(socket, 'writepacket', host, 4444);

