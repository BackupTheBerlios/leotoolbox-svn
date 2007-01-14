function wait_for_scanner(log_pointer)
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  12/01/2007    Created

fprintf('listening for trigger: ');

while true
    stroke = getkey;
    if (char(stroke) == 't')
        fprintf( 'got trigger pulse from scanner\n');
        log('got  trigger pulse from scanner', log_pointer);
    break;
    end
end; 
