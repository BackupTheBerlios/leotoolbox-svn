function event_table(events)


for i = 1:size(events, 2)
    
    event = events(i);
    description = get(event, 'name');
    duration = get(event, 'duration');
    
    fprintf('%d.\t%s\t\t%d\n', i, description, duration);
end