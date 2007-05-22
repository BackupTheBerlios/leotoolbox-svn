function event_duration_plot(events)

d = []
for i = 1:size(events, 2)
      d(i) = get(events(i), 'duration');
end

plot(d);