function[events] = localisation_events (images)

i1 = picture;
i1 = add(i1, 'bitmap', );
si1 = stimulus;    
si1 = set(si1, 'data', i1);
instructions(1) = stimulus_event('stimulus', si1, 'duration', 5000);
