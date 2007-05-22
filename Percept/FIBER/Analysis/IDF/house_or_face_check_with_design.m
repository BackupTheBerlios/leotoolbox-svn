function[ trials exportfile ] = house_or_face_check_with_design( trials, starting_position, plotting, exporting, designfile )

%% load experiment design

design = load(designfile);
data = design.ordering;

%% experiment started with circular display as first trigger
stimulus_index = 1; %% counter to iterate the designmatrix 
block_design = [1 1 1 1 1 0 0]; % five times stimulus, followed by rest + instructions;
experiment = repmat(block_design, 1, (length(trials) - starting_position));

instructions = {'look at houses', 'look at faces', 'free viewing'};
instruction_index = 0; 

trial_index = 1;

%% fmri volumes, for plotting it relative
starting_volume_position = starting_position;


TR = 2000;
NUMBER_OF_SCANS = 504;

%% plot settings
if (plotting)
    figure;
    subplot(2,1,1);
    title(trials(1).filename);
    hold on;
    ylim([0 9]);
    subplot(2,1,2);
    title(trials(1).filename);
    hold on;
    ylim([-2 2]);
    set(gca,'YTick',[-2:1:2])
end;

%% open exportfile
if (exporting)
    
    filename = trials(1).filename;
    slash = '/';
    
    pos = findstr(filename, slash);
    name_offset = pos(length(pos))+1;
    
    orig_name = filename(name_offset:length(filename));
    
    
    exportfile = ['/tmp/fixations_' orig_name '_run_' num2str(run) '_offset_' num2str(starting_position) '.txt'] ;
    fp = fopen(exportfile, 'w');
    fprintf('exportfile : %s\n', exportfile);
    header = 'volume\ttrial\tfixation\tstart (s)\tend (s)\tduration (s)\timage no.\tcorrect\tcase\thouse_or_face\ttask\n';
    % case 
    % 0 = baseline fixation from rest stimulus
    % 1 = look at houses / houses watched
    % 2 = look at houses / faces watched
    % 3 = look at houses / other watched 
    
    % 4 = look at faces  /faces watched
    % 5 = look at faces / houses watched
    % 6 = look at faces / other watched
    
    % 7 = free viewing / houses watched
    % 8 = free viewing / faces watched
    % 9 = free viewing / other watched
    
    fprintf(fp, header);
    logformat = '%d\t%d\t%d\t%4.2f\t%4.2f\t%2.3f\t%d\t%d\t%d\t';
    
    xvolumes = 1; 
    volumes = [trials(starting_position).start:xvolumes*TR:trials(length(trials)).start];
    max_volumes = NUMBER_OF_SCANS / xvolumes;
    %%volumes = volumes(1:max_volumes);

end;

%% hack to check for drift correct
rest_fixations = struct('fixations', []);
rfix_counter   = 1;

%% for every trial, beginning at starting_position, until either end of ...
%  trials, or end of experiment 

offset = trials(starting_position).fixations(1).start;

for t = starting_position:min(length(trials), length(experiment)) 

    trial = trials(t);

    if ( (experiment(trial_index) == 1) && (stimulus_index < size(data,1)+1)) %% stimulus image

        %% check for increasing instruction_index
        if mod(stimulus_index, 5) == 1
            instruction_index = instruction_index + 1;
            if instruction_index == 4 
                instruction_index = 1;
            end;
            
            if (plotting)
                subplot(2,1,1);
                y_data = linspace(-2, 9, 100);
                x_data = repmat(trial.fixations(1).start, 1, 100);
                plot(x_data, y_data, 'k:');
                subplot(2,1,2);
                plot(x_data, y_data, 'k:'); 
            end;
        end;
        
        

        fprintf('trial %d : stimulus %d (instruction: %s)\n', t, stimulus_index, instructions{instruction_index});
        
        %% locate the array of images presented during the stimulus
        stimulus = data(stimulus_index,:); 

        
        fixations = trial.fixations;       
        %% for all fixations in this trial, ... 
        for i=1:length(fixations)        
            
            volume_index = round((fixations(i).start - offset) / TR) + 1; %% add one, since starting with volume 1
            hit = fixations(i).hit{1};
            %% check for area hit and ...
            if (hit > 0)                
                %% 1) lookup the image of attention
                hit_image = stimulus(hit);
                value = 0;
                %% 2) create labels for this hit
                if ( hit_image > 30)
                    text = {['face (image ' num2str(hit_image - 30) ')']};
                    value = 1;
                    inspected = 'face';
                else
                    text = {['house (image ' num2str(hit_image) ')']};
                    value = -1;
                    inspected = 'house';
                end;
                %% 3) store it in fixations            
                fixations(i).hit{2} = text;
                fixations(i).hit{3} = value;
                [color corrected_value] = get_plot_color(instruction_index, value);
                fixations(i).hit{4} = corrected_value;
                if (plotting)
                  fixation_plot(fixations, hit, value, i, color);
                end;
                switch(instruction_index)
                    case 1
                        switch(value)
                            case -1 
                                class = 1;
                            case 1 
                                class = 2;
                            otherwise 
                                class = 3;
                        end
                    case 2
                        switch(value)
                            case 1 
                                class = 4;
                            case -1 
                                class = 5;
                            otherwise
                                class = 6;
                        end
                    case 3
                        switch(value)
                            case 1
                                class = 7;
                            case -1
                                class = 8;
                            otherwise
                                class = 9;
                        end
                end
                        
                     
                
                
                %% 5) export to file
                if (exporting)
                  
                  starting = (fixations(i).start - offset) / 1000;
                  ending   = (fixations(i).end - offset) / 1000;
                  duration = fixations(i).duration / 1000;
                  instruction = instructions{instruction_index};
                  fprintf(fp, logformat, volume_index, t, i, ...
                          starting, ending, duration, hit_image, corrected_value, class);
                  fprintf(fp, '%s\t%s\n', inspected, instruction);
                       
                end;
            else %% hit <= 0, so no areas found
               switch(instruction_index)
                    case 1
                       class = 3;
                    case 2
                       class = 6;
                    case 3
                       class = 9;
                end

            if (exporting) %% also export 'wrong' fixations
                  starting = (fixations(i).start - offset) / 1000;
                  ending   = (fixations(i).end - offset) / 1000;
                  duration = fixations(i).duration / 1000;
                  instruction = instructions{instruction_index};
                  fprintf(fp, logformat, volume_index, t, i, ...
                          starting, ending, duration, 0, 0, class);
                  fprintf(fp, '%s\t%s\n', '', instruction);
            end;
            end
        end
        %% reassign the labels, since this trial is done
        trial.fixations = fixations;
        trials(t) = trial;
        
        %% increase stimulus_index
        stimulus_index = stimulus_index +1;

    else
      fprintf('trial %d : skipping\n', t);
      
      if ( exporting)
          fixations = trial.fixations;       
          
          %%dirty hack to check drift
          rest_fixations(rfix_counter).fixations = fixations;
          rfix_counter = rfix_counter + 1;
        %% for all fixations in this trial, ... 
        class = 0;
        for i=1:length(fixations)        
                  
                  starting = (fixations(i).start - offset) / 1000;
                  ending   = (fixations(i).end - offset) / 1000;
                  duration = fixations(i).duration / 1000;
                  instruction = instructions{instruction_index};
                  fprintf(fp, logformat, volume_index, t, i, ...
                          starting, ending, duration, 0, 0, class);
                  fprintf(fp, '%s\t%s\n', '', 'fixation cross');
        end
      end
      end

    trial_index = trial_index + 1;  %% increase trial counter
end;

%% plot settings
if (plotting)
       
    labels = {'','houses','other','faces',''};
    set(gca, 'Yticklabel', labels);    
    xvolumes =25;

    volumes = [trials(starting_position).start:xvolumes*TR:trials(length(trials)).start];
    max_volumes = NUMBER_OF_SCANS / xvolumes;
    volumes = volumes(1:max_volumes);

    subplot(2,1,1);
    set(gca, 'XTick', volumes); 
    set(gca, 'XTicklabel', 0:xvolumes:NUMBER_OF_SCANS);
    xlabel('Volumes');
    subplot(2,1,2);
    set(gca, 'XTick', volumes); 
    set(gca, 'XTicklabel', 0:xvolumes:NUMBER_OF_SCANS);
    xlabel('Volumes');
    
end;

assignin('base', 'rest_fixations', rest_fixations);

if (exporting)
 
    fclose(fp);
    if nargout == 0
        cmd = ['open ' exportfile];
        system(cmd);
    end
end










%% plot internal function
function[] = fixation_plot(fixations, hit, value, i, color)
  duration = fixations(i).duration;
  start =   fixations(i).start;

  %% area number for a given duration
  y_data =  repmat(hit , 1, duration);
  %% target label for a given duration
  hf_data = repmat(value, 1, duration);
                    
  subplot(2,1,1);
  plot(start:start+duration-1, y_data, color,'LineWidth', 3);
  subplot(2,1,2);
  plot(start:start+duration-1, hf_data, color,'LineWidth', 3);
  
  
function [ color, corrected_value ] = get_plot_color(instruction_index, value)

if (((instruction_index == 1) && (value == -1)) || ...
    ((instruction_index == 2) && (value ==  1)) || ...
     (instruction_index == 3))
      color = 'g';
      if instruction_index == 3
          color = 'b';
      end;
      corrected_value = 1;
  else
      color = 'r';
      corrected_value = -1;

end;
      



