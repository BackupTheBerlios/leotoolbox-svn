function[] = finalize( parameters )
%
% default cleaning up after the experiment
%
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

%close screen
Screen('CloseAll');
ShowCursor;
fprintf('All done...\n');

if (nargin == 1)
            
    switch ( parameters )
        case 'Screen'
            fprintf('Closing visual...\n');
            Screen('CloseAll');
        case 'Eyelink'
            %close eyelink
            fprintf('Closing eyelink connection...\n');
            Eyelink('StopRecording');
            Eyelink('Shutdown');
        case 'All'
            fprintf('Closing visual...\n');
            Screen('CloseAll');
            %close eyelink
            fprintf('Closing eyelink connection...\n');
            Eyelink('StopRecording');
            Eyelink('Shutdown');
        otherwise
            error('Possible finalize calls are : { Screen, Eyelink, All }');
    end;
end

if (nargin == 0)
    fprintf('Closing visual...\n');
    Screen('CloseAll');
    %close eyelink
    %fprintf('Closing eyelink connection...\n');
    %Eyelink('StopRecording');
    %Eyelink('Shutdown');
end;