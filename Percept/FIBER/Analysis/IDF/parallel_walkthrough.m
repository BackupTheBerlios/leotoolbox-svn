function[] = parallel_walkthrough(pictures, trials1, t_offset1,...
                                  trials2, t_offset2,...
                                  trials3, t_offset3,...
                                  trials4, t_offset4, run)                                                           
%%
%   Walkthrough provides a simulation of the experiments with recorded eye
%   data. parralel_walkthrough uses multiple subject data and presents it
%   on the same screen   
%
%   Synopsis : walkthrough ( pictures, 
%                            trials, 
%                            run, 
%                            trial_offset,
%                            speed_factor)
%   pictures     : array of picture objects to iterate
%                  (walkthrough(0, ... ) loads in defaults
%   trials       : trial data from readIDFevents
%   run          : 1 or 2
%   trial_offset : which trial is the first stimulus ?
%   speed_factor : unused, might be used to control the speed of the
%                  simulation, currently space lets you walk through
%                  the simulation
%
%   J.B.C. Marsman, 19/02/2007
%   University Medical Center Groningen
%
%
if pictures == 0
   images = load_images;
   pictures = create_pictures(images, run);
   
end;

%% recalculate trial hits for display purposes, 'preprocessing step'
trials1 = hit_test( trials1, run, t_offset1);
trials1 = house_or_face_check( trials1, t_offset1, run, 0, 0);

trials2 = hit_test( trials2, run, t_offset2);
trials2 = house_or_face_check( trials2, t_offset2, run, 0, 0);

trials3 = hit_test( trials3, run, t_offset3);
trials3 = house_or_face_check( trials3, t_offset2, run, 0, 0);

trials4 = hit_test( trials4, run, t_offset4);
trials4 = house_or_face_check( trials4, t_offset2, run, 0, 0);

%% get hitdata
%trials = hit_test(trials);
%trials = house_or_face_check(trials, trial_offset, run, 0, 0);

debug = 0;

for i=1:size(pictures ,2)
    
    s = stimulus;    
    stimuli(i) = set(s, 'data', pictures(i));
end;
    assignin('base', 's', stimuli);

%% setup screens
screens=Screen('Screens');
screenNumber=max(screens);

Screen('Preference', 'SkipSyncTests', 1);
[w, wRect] = Screen('OpenWindow', screenNumber, 0,[], 32);       
Screen('BlendFunction', w, GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA);

Screen('TextFont',  w, 'Arial');
Screen('TextSize',  w, 20);
Screen('TextStyle', w, 1+2);

%% Now the fun part begins, divide the wRect up into 4 areas...

wRect1 = [wRect(1) wRect(1) wRect(3)/2 wRect(4)/2];
wRect2 = [wRect(3)/2 wRect(1) wRect(3) wRect(4)/2];
wRect3 = [wRect(1) wRect(4)/2 wRect(3)/2 wRect(4)];
wRect4 = [wRect(3)/2 wRect(4)/2 wRect(3) wRect(4)];


WaitSecs(1);
stimuli_index =1;

% offscreen_index = 1;

%% iterate trials
trial_index = 1;

current_trial1 = t_offset1;
current_trial2 = t_offset2;
current_trial3 = t_offset3;
current_trial4 = t_offset4;



task_index = 1;

while ( (current_trial1 < length(trials1)) && (stimuli_index <= length(stimuli)))
    
    if (mod(trial_index, 6) == 0)
        trial_index = 1; 
        task_index = task_index +1;
        if (task_index == 4)
            task_index = 1;
        end;
        current_tria1l = current_trial1 + 2; %% skip fixation and instructions screens
        current_tria12 = current_trial2 + 2; %% skip fixation and instructions screens
        current_tria13 = current_trial3 + 2; %% skip fixation and instructions screens
        current_tria14 = current_trial4 + 2; %% skip fixation and instructions screens

    
    end
    trial1_i = trials1(current_trial1);
    trial2_i = trials2(current_trial2);
    trial3_i = trials3(current_trial3);
    trial4_i = trials4(current_trial4);

    plot_fixations_on_stimulus( stimuli(stimuli_index), trial1_i.fixations, w, wRect1, task_index, stimuli_index, current_trial1, trial1_i.duration );
    plot_fixations_on_stimulus( stimuli(stimuli_index), trial2_i.fixations, w, wRect2, task_index, stimuli_index, current_trial2, trial2_i.duration );
    plot_fixations_on_stimulus( stimuli(stimuli_index), trial3_i.fixations, w, wRect3, task_index, stimuli_index, current_trial3, trial3_i.duration );
    plot_fixations_on_stimulus( stimuli(stimuli_index), trial4_i.fixations, w, wRect4, task_index, stimuli_index, current_trial4, trial4_i.duration );
    [vbl sot ft m bp] = Screen('Flip', w);

    pause;
    stimuli_index = stimuli_index + 1;
    trial_index = trial_index + 1;

    if (debug)
        break;
    end;
    current_trial1 = current_trial1 + 1;
    current_trial2 = current_trial2 + 1;
    current_trial3 = current_trial3 + 1;
    current_trial4 = current_trial4 + 1;

end;

Screen('CloseAll');

%%



function[] = plot_fixations_on_stimulus(stimulus, fixations, w, wRect, task_index, stimuli_index, trial_index, duration)

   draw_in_buffer(stimulus, w, wRect);
   titles = {'look at houses', 'look at faces', 'free viewing'};

   s = ['s# ' num2str(stimuli_index)];
   tr = ['t# ' num2str(trial_index)]; 
   
   t = [ titles{task_index} ', ' s ', ' tr ', ' num2str(length(fixations))   ' fixations over ' num2str(duration / 1000) ' s'];
   
   Screen('DrawText', w, t, 10, 10, [0 0 0]);

   draw_hit_circles(w, wRect);
   
   colors = 255 * autumn(length(fixations));
   radius = 15;
   max_fix_duration = fixations(1).duration;
   for f = 1:length(fixations)
       if (fixations(f).duration > max_fix_duration)
           max_fix_duration = fixations(f).duration;
       end;
   end
   for f = 1:length(fixations)
       
       x = fixations(f).location_x;
       y = fixations(f).location_y;
       
       %% h{1} = area_no, {h2} = label, h{3} = label weight, h{4} = correct
       %% object inspected
       hit   = fixations(f).hit{4}; 
       [x y] = rescale(x, y, wRect);
       
       coord = [(x - radius) (y - radius) (x + radius) (y + radius)];
       alpha = 128 + ((127 / max_fix_duration) * fixations(f).duration);
      
       %% color represents number of fixation
       color = colors(f,:);
       %% transparency represents duration of each fixation
       color(4) = alpha;
       %% open circle means no hit, filled circle means hit
       if (hit == 1)
           Screen('FillOval', w, color, coord);	% draw fixation dot (flip erases it)
       else
           if (length(coord) == 4)
               Screen('DrawArc', w, color, coord, 0, 360);
           end;
       end;
   end;

   
%%      
function[ offscreen_index ] = gaze_transition(stimulus, start_fixation, end_fixation, w, wRect, title, duration, offscreen_index);
nframes = 10;

x1 = start_fixation.location_x;
x2 = end_fixation.location_x;
y1 = start_fixation.location_y;
y2 = end_fixation.location_y;

nframes = round((end_fixation.start - start_fixation.end ) / 5);

if (nframes > 100)
    fprintf('High interfixation value found : %d\n', nframes);
    nframes = 100;
else
    fprintf('interfixation value found : %d\n', nframes * 5);
    end
[x1 y1] = rescale(x1, y1, wRect);
[x2 y2] = rescale(x2, y2, wRect);

radius = 10;

course_x = round(linspace(x1, x2, nframes));
course_y = round(linspace(y1, y2, nframes));

Screen('TextFont',  w, 'Arial');
Screen('TextSize',  w, 20);
Screen('TextStyle', w, 1+2);

title = [title ' (' num2str(x1) ',' num2str(y1) ') - (' num2str(x2) ',' num2str(y2) ')'];
%%
for i = 1:nframes
    
   coord = [(course_x(i) - radius) (course_y(i)- radius) (course_x(i) + radius) (course_y(i) + radius)];
   draw_in_buffer(stimulus, w, wRect);
   Screen('DrawText', w, title, 10, 10, [0 0 0]);
   Screen('FillOval', w, [255 0 0], coord);	% draw fixation dot (flip erases it)
   [vbl sot ft m bp] = Screen('Flip', w);
   %%save_to_file(w, offscreen_index);
   %%offscreen_index = offscreen_index + 1;
end   


%% load images
function[ images ] =  load_images
   images(1:30) = load_bitmaps('/Users/marsman/Desktop/Houses/');
   clear bitmaps
   images(31:60) = load_bitmaps('/Users/marsman/Desktop/Faces/');
   assignin('base', 'bitmaps', images);


   
%%   
function [scaled_x scaled_y] = rescale(gaze_x, gaze_y, wRect)
   recorded_x = 1024;
   recorded_y = 768;
   
   scaled_x = (wRect(3) / recorded_x) * gaze_x + 50;
   scaled_y = (wRect(4) / recorded_y) * gaze_y;
  
%%
function[] = save_to_file( window, index )
    offscreen = Screen(window, 'GetImage');
    filename = ['/Users/marsman/movie_sample_eyetracking-' num2str(index) '.jpg'];
    imwrite(offscreen, filename, 'JPG');

%%  
function [centers] = draw_hit_circles(w, wRect)
    [areas, centers] = areas_of_interest(wRect(3), wRect(4), 0);
    radius = 110;
    for c = 1:length(centers)
        pos = centers(c);
        coord = [(pos.x - radius) (pos.y - radius) (pos.x + radius) (pos.y + radius)];
        Screen('DrawArc', w, [0 0 255 128], coord, 0, 360);
    end
                                      