function[events] = localisation_events (images)

instruction = 'fixate on the object';
instr_picture = picture;
instr_picture = add(instr_picture, 'text', instruction);
instruction_stim = stimulus(instr_picture);
is = stimulus;    
is = set(is, 'data', instr_picture);
is_event = stimulus_event('stimulus', is, 'duration', 5000);
is_event = set(is_event, 'name', 'localisation instruction');



rest_picture = picture;
rest_picture = add(rest_picture, 'text' ,'+','location', [512 384]);
stimulus_rest = stimulus(rest_picture);
rs = stimulus;    
rs = set(rs, 'data', rest_picture);
inserted_event = stimulus_event('stimulus', rs, 'duration', 5000);
inserted_event = set(inserted_event, 'name', 'fixation cross');

index = 1;
events(1:5) = create_localisation_screens(1,5, 'house', images);
events(6) = inserted_event;
events(7:11) = create_localisation_screens(1,5, 'face', images);
events(12) = inserted_event;

events(13:17) = create_localisation_screens(6,10, 'house', images);
events(18) = inserted_event;
events(19:23) = create_localisation_screens(6,10, 'face', images);
events(24) = inserted_event;

events(25:29) = create_localisation_screens(6,10, 'face', images);
events(30) = inserted_event;
events(31:35) = create_localisation_screens(6,10, 'house', images);
events(36) = inserted_event;

events(37:41) = create_localisation_screens(6,10, 'house', images);
events(42) = inserted_event;
events(43:47) = create_localisation_screens(6,10, 'face', images);
events(48) = inserted_event;


assignin('base', 'localisations', events);


function[series] = create_localisation_screens(n1, n2, type, images)

serie_index = 1; 
for i = n1:n2
    p = picture;
    if( strcmp(type, 'face'))
        index = i + 30;
        p = add(p, 'bitmap', images(i + 30) );
    else
        index = i;
        p = add(p, 'bitmap', images(i) );
    end;
    sp = stimulus;    
    sp = set(sp, 'data', p);
    
    series(serie_index) = stimulus_event('stimulus', sp, 'duration', 2000);
    name = ['localisation stimulus ' num2str(serie_index) '(' type ', image : ' num2str(index) ')' ];
    series(serie_index) = set(series(serie_index), 'name', name);
    serie_index = serie_index +1;
end;
