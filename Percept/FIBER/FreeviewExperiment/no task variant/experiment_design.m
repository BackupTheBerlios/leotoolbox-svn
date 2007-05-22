function[ ] = experiment_design
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 
%  Main routine for the first experiment:
%  - Block design, showing 4 houses and 4 faces circular
%  - Also using the eyetracker iViewX for reference data

%  Revision history :
%
%  9/12/2006    Created
PsychJavaTrouble;

[log_pointer, logfilename] = createlog('/Users/marsman/Desktop/','houses_versus_faces');
diaryfile = [logfilename '.matlablog'];

dummymode = 1;


run = evalin('base', 'run')
try 
    images = evalin('base', 'bitmaps');
    if (class(images) == 'bitmap')
        fprintf('Using images which are currently available in working memory\n');
    else
      fprintf('Corrupt events exist, reloading required\n');
      images = load_images;
    end;
catch
    fprintf('No bitmaps found. Loading them in :\n');
    images = load_images;
end;
  
all_events = load_in_events ( images , run);
assignin('base', 'events', all_events);  
parameterlist = parameters;
  
%% Open logfile.
diary diaryfile; diary on;
mlog('logfile created', log_pointer);


%% Setup Iview connection and Screen
[s, window, wRect, host] = iview_start;

ivx = iViewXInitDefaults;
ivx.dummymode = dummymode;

ivx = iViewX('datafile', ivx, logfilename);
ivx = iViewX('calibrate', ivx);

ListenChar(2);
%% Start with calibration and wait for scanner
fprintf('listening for trigger:\n');
while true
    stroke = GetChar;
    if (char(stroke) == 'e')
        starting_time = now;
        mlog('going into experiment run', log_pointer);    
        fprintf('Starting experiment\n');
        fprintf('Using experiment design :\t%d\n', run);
    break;
    end
    if (char(stroke) == 'c')
        iview_calibrate(s, host, window, wRect);
    end;
end; 

%% Clear previous Eyetracker data
clear_buffer = ['ET_CLR'];
iview_send(s, clear_buffer, host);

%% Start recording of eyetracker
start_recording = ['ET_REC'];
iview_send(s, start_recording, host);

%% Run the experiment
parameterlist = present(all_events, window, wRect, parameterlist, logfilename, log_pointer, s, host);

WaitSecs(3);
%% Stop the recording of eyetracker
stop_recording = ['ET_STP'];
iview_send(s, stop_recording, host);

%% Save final dataset of Eyetracker data
save_command = ['ET_SAV "D:\JanBernard\housesfaces\' logfilename '-final.idf"' ];
iview_send(s, save_command, host);





function[ images ] =  load_images
   images(1:30) = load_bitmaps('/Users/marsman/Desktop/Houses/');
   clear bitmaps
   images(31:60) = load_bitmaps('/Users/marsman/Desktop/Faces/');
   assignin('base', 'bitmaps', images);




function[ all_events ] =  load_in_events( images, run )
   pictures = create_pictures(images, run);
   stimuli = create_stimuli(pictures);
   %assignin('base', 'raw_images', images);
   %assignin('base', 'stimuli', stimuli);
   localisations = localisation_events( images );

   for s = 1:size(stimuli, 2),
      s_events(s) = stimulus_event('stimulus', stimuli(s), 'duration', 12000);
      name = ['stimulus event ' num2str(s)];
      s_events(s) = set(s_events(s), 'name', name);
   end

   stimulus_events = add_resting_periods(s_events);

   number1 = size(localisations, 2);
   number2 = size(stimulus_events, 2);
   all_events(1:number1) = localisations;
   
   all_events(number1+1:number2+number1) = stimulus_events;
   all_events = stimulus_events; 