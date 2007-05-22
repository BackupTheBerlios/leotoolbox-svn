function [ trials ] = extractTrials( data )

%% no fixaton saccade info, plain stream
set_separator_index = 3;
  type_index = 2;
  trial_index = 1;
  trials = struct('number', trial_index, ...
                  'data', [], ...
                  'duration', 0);

  data = data.samples;
  previous_set = data{ set_separator_index }(1);
  data_index = 1;
  
  starting = data{1}(1);
  for i = 1: size(data{1}, 1)
      current_set = data{ set_separator_index }(i);

      if (current_set ~= previous_set)
          ending = data{1}(i);
          trials(trial_index).number = previous_set;
          trials(trial_index).data =   datapoint;
          trials(trial_index).duration = (ending - starting) / 1000000; % ms conversion
          trial_index = trial_index + 1;         
          datapoint = cell(1,7);
          data_index = 1;        
          starting = data{1}(i);
          
      end;
      
      datapoint{1}(data_index) = data{1}(i);
      datapoint{2}(data_index) = data{6}(i);
      datapoint{3}(data_index) = data{7}(i);
      datapoint{4}(data_index) = data{8}(i);
      datapoint{5}(data_index) = data{9}(i);
      datapoint{6}(data_index) = data{10}(i);
      datapoint{7}(data_index) = data{11}(i);
      data_index = data_index +1;
         
      previous_set = current_set;
      
  end;
  
  %% PARAMETERS TO SET WITH NEW EYETRACKER DATA

  [a, area_centers] = areas_of_interest;
  radius = 110;
  starting_pos = 60;
  run = 1;
  
  %trials = hittest(trials, area_centers, radius)
  %trials = house_or_face_check(trials, starting_pos, run);

  

