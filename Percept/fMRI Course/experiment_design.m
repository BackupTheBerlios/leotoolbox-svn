function[ ] = experiment_design


try 
    all_events = evalin('base', 'events');
    if (class(all_events) == 'stimulus_event')
        fprintf('Using images which are currently available in working memory\n');
    else
      fprintf('Corrupt events exist, reloading required\n');
      all_events = load_in_events;
    end;
catch
    fprintf('No events found. Loading them in :\n');
    all_events = load_in_events;
end;
  
  
parameterlist = parameters;
  
%% Open logfile.
[log_pointer, logfilename] = createlog('/Users/justvanes/Desktop/Results/','houses_versus_faces');

%% Setup Iview connection and Screen
[s, window, wRect, host] = iview_start;



fprintf('listening for trigger:\n');
while true
    stroke = getkey;
    if (char(stroke) == 't')
        starting_time = now;
        fprintf('Starting experiment\n');
    break;
    end
    if (char(stroke) == 'c')
        iview_calibrate(s, host, window, wRect);
    end;
end; 

clear_buffer = ['ET_CLR'];
iview_send(s, clear_buffer, host);

start_recording = ['ET_REC'];
iview_send(s, start_recording, host);
parameterlist = present(all_events, window, wRect, parameterlist, log_pointer, s, host);

stop_recording = ['ET_STP'];
iview_send(s, stop_recording, host);

save_command = ['ET_SAV "D:\JanBernard\housesfaces\' logfilename '.idf"' ];
iview_send(s, save_command, host);


function[ all_events ] =  load_in_events()
   images(1:30) = load_bitmaps('/Users/justvanes/Desktop/Houses/');
   clear bitmaps
   images(31:60) = load_bitmaps('/Users/justvanes/Desktop/Faces/');
   pictures = create_pictures(images);
   stimuli = create_stimuli(pictures);
   %assignin('base', 'raw_images', images);
   %assignin('base', 'stimuli', stimuli);
   localisations = localisation_events( images );

   for s = 1:size(stimuli, 2),
      s_events(s) = stimulus_event('stimulus', stimuli(s), 'duration', 12000);
   end

   stimulus_events = add_resting_periods(s_events);

   all_events(1:12) = localisations;
   all_events(13:133) = stimulus_events;
   assignin('base', 'events', all_events);