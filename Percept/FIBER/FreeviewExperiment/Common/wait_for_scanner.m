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
FlushEvents;

while true
    [stroke when]= GetChar; %% getkey
    if (char(stroke) == 't')
        fprintf( 'got trigger pulse from scanner\n');
        mlog(['got  trigger pulse from scanner'], log_pointer);
        FlushEvents;
        break;
    end
end; 
