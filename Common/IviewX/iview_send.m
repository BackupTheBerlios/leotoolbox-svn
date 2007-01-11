function[result] = iview_send(socket,  command, host )

finished_command = [command setstr(10)];
try,
    pnet(socket, 'write', finished_command);
    result = pnet(socket, 'writepacket', host, 4444);
catch
    fprintf('Failed to send command!\n');
end;
