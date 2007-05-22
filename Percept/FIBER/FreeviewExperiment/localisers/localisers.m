function[loc_series] = localisers(number, duration)
%%
%  Create localiser screens with req. duration 
%  n-back task of 2
%

%% -- EXPERIMENT SETTINGS -----

LOGPATH = '/Users/marsman/Documents/Experiments/070419_houses_versus_faces/Experiment logging/localisers/';
RUN     = 1;
CLASS_SWITCH = 30;
LASTIMAGE = 30;
LANGUAGE = 'nl';
NBACK = 0;

%% -- PTB HACKS

PsychJavaTrouble;
Priority(9); 

%% -- LOG SETTINGS

[log_pointer, logfilename] = createlog(LOGPATH,'houses_versus_faces_localiser');
diaryfile = [logfilename '.matlablog']
diary(diaryfile); diary on;
mlog('logfile created', log_pointer);

%% -- SCREEN OPENING

screennumber = max(Screen('Screens'));
Screen('Preference','SkipSyncTests', 0);
[window, wRect] = Screen('OpenWindow', screennumber);
ifi = Screen('GetFlipInterval', window, 200) * 1000;
Screen('TextFont', window, 'Tahoma');

try
 bitmaps = evalin('base', 'bitmaps');
catch
    fprintf('Critical error !! bitmaps do not exist');
    images = load_images;
    bitmaps = evalin('base', 'bitmaps');

end;

%% -- create initial task instruction

if NBACK > 0,
    instruction_nl = 'Is het laatst getoonde object gelijk aan de ?';
    instruction_en = 'Is te last shown object the same?';
else
    instruction_nl = 'Kijk naar de objecten.';
    instruction_en = 'Look closely';
end


%% -- create instruction screen

events(1)= instruction_screen(5000, instruction_nl);

number = 15; 

for i = 1:8
    class1 = randperm(LASTIMAGE);
    series = class1(1:number);
    faces_block  = localiser_screens(series, 'face', 750 - ifi, bitmaps);
    houses_block = localiser_screens(series, 'house', 750 - ifi, bitmaps);
    
    events = append(events, faces_block);
    events = append(events, houses_block);    
end

if NBACK > 0,
    if (rand > 0.6)
        series(number- NBACK) = series(number);
    end
end
assignin('base', 'events', events);

%

gss = ['Starting experiment with GetSecs = ' num2str(GetSecs)];
mlog(gss, log_pointer);
present(events, window, wRect, 0, log_pointer, 0, '');


pauseScreen(window);

Priority(0);
diary;
function[ images ] =  load_images
   images(1:30) = load_bitmaps('/Users/marsman/Documents/Experiments/070419_houses_versus_faces/Stimuli/Houses/', 1);
   clear bitmaps
   images(31:60) = load_bitmaps('/Users/marsman/Documents/Experiments/070419_houses_versus_faces/Stimuli/Faces/', 1);
   assignin('base', 'bitmaps', images);
   
   
function[] = pauseScreen(window)
    Screen('FillRect', window, 0);
    Screen('Flip', window);

    
function[ls] = localiser_screens(n_array, type, duration, images)
    for n = 1:length(n_array)
        
        p = picture;
        if( strcmp(type, 'face'))
            p = add(p, 'bitmap', images(n_array(n) + 30) );
        else
            p = add(p, 'bitmap', images(n_array(n)) );
        end;
    
        sp = stimulus;    
        sp = set(sp, 'data', p);
    
        ls(n) = stimulus_event('stimulus', sp, 'duration', duration);
        name = ['localisation stimulus:'  '(' type ' , image : ' num2str(n_array(n)) ')' ];
        ls(n) = set(ls(n), 'name', name);
        
        if (n == 1)
            ls(n) = set(ls(n), 'trigger', 'before');
        end
    end

    ls(n+1) = fixation_cross(7000);
    
    
function[ fs] = fixation_cross(duration)
    rest_picture = picture;
    rest_picture = add(rest_picture, 'text' ,'+');
    stimulus_rest = stimulus(rest_picture);
    rs = stimulus;    
    rs = set(rs, 'data', rest_picture);
    fs = stimulus_event('stimulus', rs, 'duration', duration);
    fs = set(fs, 'name', 'fixation cross');

%%
function[is] = instruction_screen(duration, text)
    instr_picture = picture;
    instr_picture = add(instr_picture, 'text', text);
    istim = stimulus;    
    istim = set(istim, 'data', instr_picture);
    is = stimulus_event('stimulus', istim, 'duration', duration);
    is = set(is, 'name', ['instruction : ' text]);
