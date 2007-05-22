function[] = validationScreen(events)

screennumber = max(Screen('Screens'));
Screen('Preference','SkipSyncTests', 0);
[window, wRect] = Screen('OpenWindow', screennumber);


starting_event = events(2); 
starting_stim  = get(starting_event, 'stimulus');

stim_pic = get(starting_stim, 'data');

stim_array = get(stim_pic, 'elements');
stimtype_array = get(stim_pic, 'elementtypes');
stim_locations = get(stim_pic, 'locations');

stim_alphas = get(stim_pic, 'alphas');

l = size(stim_array, 2);

for i = 1:size(stim_array, 2)
  stim_alphas{i} = 0.5;
  stim_alphas{i +l} = 1;
  loc = stim_locations{i};
  stim_pic = add(stim_pic, 'text', num2str(i), 'location', loc, 'position', 'rel', 'fontsize', 75);
  
end

stim_pic = set(stim_pic, 'alphas', 0, stim_alphas);
get(stim_pic, 'alphas')


stim_pic = add(stim_pic, 'text', '+', 'location', [0 0]);
present(stim_pic);