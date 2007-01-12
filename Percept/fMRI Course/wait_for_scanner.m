function wait_for_scanner(log_pointer)

fprintf('listening for trigger:\n');

while true
    stroke = getkey;
    if (char(stroke) == 't')
        log('got  trigger pulse from scanner', log_pointer);
    break;
    end
end; 
