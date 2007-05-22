function [ total_time ] = duration(stimulus_events)
TR = 2;

total_time = 0;
for i = 1:size(stimulus_events, 2),
    
    se = stimulus_events(i);    
    total_time = total_time + get(se, 'duration');
    trigger = get(se, 'trigger');
    
    if (strcmp(trigger, 'before') || strcmp(trigger, 'after'))
        total_time = total_time + (0.5 * TR * 1000);
    end
end;

total_time = total_time + 20000;


secs = total_time / 1000;
minutes = floor( secs / 60);
volumes = ceil(secs / TR);
rems = round(secs - (minutes * 60));

if nargout == 0
    fprintf('about %s minutes, %d\n', num2str(minutes), rems);
    fprintf('volumes : %d\n, TR = 2s\n', volumes);
end