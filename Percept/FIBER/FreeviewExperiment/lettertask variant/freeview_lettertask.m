function[ ] = freeview_lettertask

%%
%  J.B.C.Marsman,
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences / 
%  Experimental Ophtalmology
%  University Medical Center Groningen
% 
%  Main routine for the first experiment:
%  - Block design, showing 4 houses and 4 faces circular
%  - Also using the eyetracker iViewX for 'input' data

%  Revision history :
%
%  9/12/2006    Created

%
%  After pilot study, renamed to freeview

% LETTER TASK VARIANT
% -------------------

clear all;
PsychJavaTrouble;

%% -- EXPERIMENT SETTINGS ---------

LOGPATH = '/Users/marsman/Documents/Experiments/070419_houses_versus_faces/Experiment logging/';
RUN     = 1;

%% -- END EXPERIMENT SETTINGS -----
idf_file = [ 'D:\JanBernard\housesfaces3\' datestr(now,'yyyymmdd-HHMM') '.idf'];

[log_pointer, logfilename] = createlog(LOGPATH,'houses_versus_faces_lettertask');
diaryfile = [logfilename '.matlablog']
diary(diaryfile); 
diary on;
mlog('logfile created', log_pointer);

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
  
all_events = load_in_events ( images , RUN);
assignin('base', 'events', all_events);  
parameterlist = parameters;
  
%% Open logfile.


%% Setup Iview connection and Screen
[s, window, wRect, host] = iview_start;

%% Start with calibration and wait for scanner
menu;


fprintf('Your choice : ');
while true   
    [stroke time]  = GetChar;
    if (stroke == 's')
        starting_time = now;
        %mlog('got starting trigger from scanner', log_pointer);
        fprintf('Starting experiment\n');
    break;
    end
    if (stroke == 'c')
        fprintf('\n\nACTION : Now click on the calibrate button of the Eyetracker PC\n');
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
parameterlist = present_lettertask(all_events, window, wRect, parameterlist, log_pointer, s, host);

WaitSecs(3);
%% Stop the recording of eyetracker
stop_recording = ['ET_STP'];
iview_send(s, stop_recording, host);

%% Save final dataset of Eyetracker data
save_command = ['ET_SAV "D:\JanBernard\housesfaces3\' logfilename '-final.idf"' ];
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

   for s = 1:size(stimuli, 2),
      s_events(s) = stimulus_event('stimulus', stimuli(s), 'duration', 12000);
      name = ['stimulus event ' num2str(s)];
      s_events(s) = set(s_events(s), 'name', name);
   end

   stimulus_events = add_resting_periods(s_events);
   all_events = stimulus_events;   
   
function[]  = menu() 
        
fprintf('================= Main menu: ======================\n');
fprintf(' - (c) starts a new calibration\n');
fprintf(' - (s) go to main loop of experiment, \n');
fprintf('       first instructions will be shown until first trigger of the scanner arrives\n');


