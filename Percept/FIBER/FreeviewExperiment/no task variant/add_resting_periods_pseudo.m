function[new_events] =  add_resting_periods( stimuli_events )
%pseudo instruction screens

index = 1;

i1 = picture;
i1 = add(i1, 'text', 'Only focus on the houses');
si1 = stimulus;    
si1 = set(si1, 'data', i1);
instructions(1) = stimulus_event('stimulus', si1, 'duration', 5000);
instructions(1) = set(instructions(1), 'name', 'instruction screen 1');

i2 = picture;
i2 = add(i2, 'text', 'Only focus on the faces');
si2 = stimulus;    
si2 = set(si2, 'data', i2);
instructions(2) = stimulus_event('stimulus', si2, 'duration', 5000);
instructions(2) = set(instructions(1), 'name', 'instruction screen 2');

i3 = picture;
i3 = add(i3, 'text', 'Focus on any image.');
si3 = stimulus;    
si3 = set(si1, 'data', i3);
instructions(3) = stimulus_event('stimulus', si3, 'duration', 5000);
instructions(3) = set(instructions(1), 'name', 'instruction screen 3');

sp = 2;

for s = 1:size(stimuli_events, 2)
        
      if (mod(s,  5) == 0)
          inserted_event = instructions(sp);
          sp = sp +1;
      else
         rest_picture = picture;
         rest_picture = add(rest_picture, 'text' ,'+','location', [512 384]);
         stimulus_rest = stimulus(rest_picture);
         rs = stimulus;    
         rs = set(rs, 'data', rest_picture);
         inserted_event = stimulus_event('stimulus', rs, 'duration', 4000);
         inserted_event = set(inserted_event, 'name', 'fixation cross');
      end  

      if (sp == 4)
          sp = 1;
      end;
      
      new_events(index) = stimuli_events(s);      
      index = index+1;
      new_events(index) = inserted_event;      
      index = index+1;
  end;
  
  length = size(new_events, 2);
  new_events(2: length+1) = new_events;
  new_events(1) = instructions(1);
  