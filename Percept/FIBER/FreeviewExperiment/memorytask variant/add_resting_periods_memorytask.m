function[new_events] =  add_resting_periods_memorytask( stimuli_events )
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  9/12/2006    Created

index = 1;

stimuli_per_task = 4;

i1 = picture;
i1 = add(i1, 'text', 'Huis');
si1 = stimulus;    
si1 = set(si1, 'data', i1);
instructions(1) = stimulus_event('stimulus', si1, 'duration', 5000);
instructions(1) = set(instructions(1), 'name', 'instruction screen (asked for houses)');
instructions(1) = set(instructions(1), 'trigger', 'after');

i2 = picture;
i2 = add(i2, 'text', 'Gezicht');
si2 = stimulus;    
si2 = set(si2, 'data', i2);
instructions(2) = stimulus_event('stimulus', si2, 'duration', 5000);
instructions(2) = set(instructions(2), 'name', 'instruction screen (asked for faces)');
instructions(2) = set(instructions(2), 'trigger', 'after');

i3 = picture;
i3 = add(i3, 'text', 'Onbekend');
si3 = stimulus;    
si3 = set(si1, 'data', i3);
instructions(3) = stimulus_event('stimulus', si3, 'duration', 5000);
instructions(3) = set(instructions(3), 'name', 'instruction screen (asked for unknown)');
instructions(3) = set(instructions(3), 'trigger', 'after');

i4 = picture;
i4 = add(i4, 'text', 'Einde van deze run.');
si4 = stimulus;    
si4 = set(si4, 'data', i4);
instructions(4) = stimulus_event('stimulus', si4, 'duration', 5000);
instructions(4) = set(instructions(4), 'name', 'ending screen ');


rest_picture = picture;
rest_picture = add(rest_picture, 'text' ,'+','location', [0 0]);
rs = stimulus;    
rs = set(rs, 'data', rest_picture);
rest_event = stimulus_event('stimulus', rs, 'duration', 10000);
rest_event = set(rest_event, 'name', 'fixation cross');
%rest_event = set(rest_event, 'driftcorrect', 1000); 

sp = 2;


 
number = size(stimuli_events,2);
 
trials_per_class = 4;
iterations = 4;
classes = 3;


index = 0;

for i = 1:iterations
     
    for c = 1:classes    
        index = index + 1;
        new_events(index) = instructions(c);
        
        for t = 1:trials_per_class
            index = index + 1;
            if (index > number)
                index_to_use = index - (floor(index / 60) * 60);
            else
                index_to_use = index;
            end
            new_events(index) = stimuli_events( index_to_use);
            index = index + 1;
            
            new_events(index) = question_picture(stimuli_events(index_to_use),  c );           
        end;
        index = index + 1;
        new_events(index) = rest_event;
    end;
    
end;


%for s = 1:size(stimuli_events, 2)
              
%      new_events(index) = stimuli_events(s);
%      index = index+1;

%      new_events(index) = question_picture(stimuli_events(s), sp);
%      index = index+1;
      
%      if (mod(s,  stimuli_per_task) == 0)
%          new_events(index) = rest_event;      
%          index = index +1;
%          new_events(index) = instructions(sp);
          
%          index = index +1;
%          sp = sp +1;
%      end;
      
      
%      if (sp == 4)
%          sp = 1;
%      end;

%  end;
  
  length = size(new_events, 2);
  new_events(length+1) = instructions(4);
 
  
function[question_event] = question_picture(event, type_stim)
   stimulus = get(event, 'stimulus');
   pic = get(stimulus, 'data');
   types = get(pic, 'elementtypes');
   elements = get(pic, 'elements');
   
   ratio = rand;
   pics = evalin('base', 'bitmaps');
   fromlastscreen = 0;   
   number_per_picture = 6;
   
   %% create arrays of houses and faces 
   j=1;k=1;
   for i = 1:number_per_picture
     if (types{i} == 1) 
       loc2(j) = i; j=j+1; end;
     if (types{i} == 2)
       loc1(k) = i; k=k+1; end;
   end
   
   if (type_stim == 1) %% look at houses
      
      if (ratio > 0.5)         
           index = round(rand* 29) + 1;
           object = pics(index);
       else
         fromlastscreen = 1;   
         ri = round(rand *(size(loc1,2)-1)) +1;
         index = loc1(ri);
         object = elements{index};
       end
   elseif (type_stim == 2) %% look at faces
       
       if (ratio > 0.5)         
           index = round(rand* 29) + 31;
           object = pics(index);
       else
         fromlastscreen = 1;   
         ri = round(rand *(size(loc1,2)-1)) +1;
         index = loc2(ri);
         object = elements{index};
       end
   else  %% free viewing
   
      if (ratio > 0.5)
         index = round(rand * (number_per_picture-1)) +1;
         object = elements{index};
      else
         fromlastscreen = 0;   
         index = round(rand * 59) + 1;
         object = pics(index);
      end
   end
   
   p = picture;
   p = add(p, 'text', 'Heb je het volgende object gezien ?');
   p = add(p, 'bitmap', object, 'location', [0 -200]);
   
   qstim = stimulus;    
   qstim = set(qstim, 'data', p);
   
   question_event = stimulus_event('stimulus', qstim, 'duration', 3000);
   tasks = {'freeview', 'houses', 'faces'};
   
   question_event = set(question_event, 'name', ['question (' tasks{type_stim} ') from-prev: ' num2str(fromlastscreen) ' index : ' num2str(index)]);
