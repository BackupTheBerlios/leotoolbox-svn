function[events] = localisation_events (images)

rest_picture = picture;
rest_picture = add(rest_picture, 'text' ,'+','location', [512 384]);
stimulus_rest = stimulus(rest_picture);
rs = stimulus;    
rs = set(rs, 'data', rest_picture);
inserted_event = stimulus_event('stimulus', rs, 'duration', 4000);
 

for i = 1:2:6
    p = picture;
    p = add(p, 'bitmap', images(i) );
    sp = stimulus;    
    sp = set(sp, 'data', p);
    
    events(i) = stimulus_event('stimulus', sp, 'duration', 5000);
    events(i+1) = inserted_event;
end;

for i = 7:2:12
    p = picture;
    size(images)
    p = add(p, 'bitmap', images(i + 27) );
    sp = stimulus;    
    sp = set(sp, 'data', p);
    
    events(i) = stimulus_event('stimulus', sp, 'duration', 5000);
    events(i+1) = inserted_event;

end;



assignin('base', 'localisations', events);