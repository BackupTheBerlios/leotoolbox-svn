function[events] = append(current_events, to_append)

events = current_events;

l = size(current_events, 2);
t = size(to_append, 2);

events = current_events;
for i = 1:t
    j = l+i;
    events(j) = to_append(i);
end;



