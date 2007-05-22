function[] = processEventData

trials = readIDFevents;

fprintf('calculating hittest\n');
trials = hittest( trials ); 

fprintf('determining start of experiment :\n');
fprintf('this usually is the first trial, lasting about 12s\n');

start_found = 0;

trial_index = 0;
while ((start_found == 0) && (trial_index < length(trials)))
    trial_index = trial_index +1;

    d = trials(trial_index).duration /1000; % in seconds
    if (d > 11 && d < 13)
        start_found = 1;
    end;
end;
      
fprintf('start of experiment @ trial %d\n', trial_index);
fprintf('calculating house or face\n');

run = 1;
trials = house_or_face_check( trials, trial_index, run); 