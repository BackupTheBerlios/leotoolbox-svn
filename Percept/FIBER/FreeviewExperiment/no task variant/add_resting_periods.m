function[new_events] =  add_resting_periods( stimuli_events )
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  9/12/2006    Created

index = 1;

i1 = picture;
i1 = add(i1, 'text', 'Only fixate on the houses');
si1 = stimulus;    
si1 = set(si1, 'data', i1);
instructions(1) = stimulus_event('stimulus', si1, 'duration', 5000);
instructions(1) = set(instructions(1), 'name', 'instruction screen (fixate on houses)');

i2 = picture;
i2 = add(i2, 'text', 'Only fixate on the faces');
si2 = stimulus;    
si2 = set(si2, 'data', i2);
instructions(2) = stimulus_event('stimulus', si2, 'duration', 5000);
instructions(2) = set(instructions(2), 'name', 'instruction screen (fixate on faces)');

i3 = picture;
i3 = add(i3, 'text', 'Fixate on any object');
si3 = stimulus;    
si3 = set(si1, 'data', i3);
instructions(3) = stimulus_event('stimulus', si3, 'duration', 5000);
instructions(3) = set(instructions(3), 'name', 'instruction screen (fixate on any)');

i4 = picture;
i4 = add(i4, 'text', 'End of the experiment.');
si4 = stimulus;    
si4 = set(si4, 'data', i4);
instructions(4) = stimulus_event('stimulus', si4, 'duration', 5000);
instructions(4) = set(instructions(4), 'name', 'ending screen ');


rest_picture = picture;
rest_picture = add(rest_picture, 'text' ,'+','location', [512 384]);
stimulus_rest = stimulus(rest_picture);
rs = stimulus;    
rs = set(rs, 'data', rest_picture);
rest_event = stimulus_event('stimulus', rs, 'duration', 10000);
rest_event = set(rest_event, 'name', 'fixation cross');

sp = 2;

for s = 1:size(stimuli_events, 2)
              
      if (mod(s, 5) == 1)
          name = get(stimuli_events(s), 'name');
          newname = ['starting ' name];
          stimuli_events(s) = set(stimuli_events(s), 'name', newname);
      end
      new_events(index) = stimuli_events(s);
      index = index+1;

      if (mod(s,  5) == 0)
          new_events(index) = rest_event;      
          index = index +1;
          new_events(index) = instructions(sp);
          sp
          index = index +1;
          sp = sp +1;
      end;
      
      
      if (sp == 4)
          sp = 1;
      end;

  end;
  
  length = size(new_events, 2);
  new_events(2: length+1) = new_events;
  new_events(1) = instructions(1);
  new_events(length+1) = instructions(4);
 
  
  