function events = create_events( stimuli, durations )
%
% Create the stimulus_events each containing 1 stimulus
%
% Usage :
%    create_events(stimuli, durations)
%
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created
if (size(stimuli, 2) ~= size(durations, 2))
    % maybe durations is a vertical array ?
    if (size(stimuli, 2) == size(durations, 1))
        durations = durations';
    else
        error('size of durations must agree with number of stimuli');
    end;
end;
for i=1:size(stimuli,2)
    s = stimuli(i);
    name = ['event ' int2str(i)]; 
    events(i) = stimulus_event('stimulus',s, 'duration', durations(i), 'name', name, 'index', i );
end;   