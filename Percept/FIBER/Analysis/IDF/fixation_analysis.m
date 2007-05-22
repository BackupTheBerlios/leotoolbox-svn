function[durations pos_avg results correct_fixations incorrect_fixations] = fixation_analysis(dataset, offset)

durations = [];
correct_fixations = [];
d = 1;

set = dataset(offset).fixations(1).set;
lastset = set;
setcounter = 1;

for i = offset: length(dataset)

    fixations = dataset(i).fixations;
    
    for f = 1:length(fixations)
        fixation = fixations(f);
        if (fixation.set ~= lastset)
            set = set + 1;
            setcounter = setcounter +1; 
            d = 1;
           
        end
        durations(setcounter, d) = fixation.duration;
        correct_fixations(setcounter, d) = fixation.hit{4} > 0;
        incorrect_fixations(setcounter, d) = fixation.hit{4} < 0;
        d = d+1;
        lastset = fixation.set;
    end
end

for f = 1:size(durations, 1)
    fixation_duration = sum(durations(f,:)) / 1000;       
end

[pos_avg results correct_fixations incorrect_fixations] = histogram_average2(durations, 1, incorrect_fixations, correct_fixations);




function[pos_avg results] = histogram_average( durations )

pos_avg = zeros(1, size(durations, 2));
counters = zeros(1, size(durations, 2));


for i = 1:size(durations, 1)
    
    for j = 1:size(durations, 2)
        try
            pos_avg(j) = pos_avg(j) + durations(i, j);               
        catch
            pos_avg(j) = durations(i,j);
        end

        if durations(i,j) ~= 0
            counters(j) = counters(j)+ 1;
        end
    end    
end

for k = 1:length(pos_avg)
   results(k) = pos_avg(k) / counters(k);
end




%% categorised results = better
function[pos_avg results correct_ones incorrect_ones] =  histogram_average2( durations, run, incorrect_ones, correct_ones )

designfile = ['/Users/marsman/Documents/Experiments/070115_houses_versus_faces/Stimuli/design/designmatrix_run' num2str(run) '.mat'];
design = load(designfile);
data = design.d;

stimulus_index = 1; %% counter to iterate the designmatrix 

block_design = [1 1 1 1 1 0 0]; % five times stimulus, followed by rest + instructions;
experiment = repmat(block_design, 1, (size(durations, 1)));

%% we want for every instruction average nth fixation times 

pos_avg = zeros(3, size(durations, 2));
counters = zeros(3, size(durations, 2));

trial_index = 1;
stimulus_index = 1;
instruction_index = 0; 

for i = 1:size(durations, 1)
    assignin('base', 'ii', instruction_index);

    %% determine instruction type
    if ( (experiment(i) == 1) && (stimulus_index < size(data,1)+1)) %% stimulus image
   
        if mod(stimulus_index, 5) == 1
            instruction_index = instruction_index + 1;
            if instruction_index == 4 
                instruction_index = 1;
            end
        end;
        
        if (instruction_index == 3)
            correct_ones(i,:) = -10;
            incorrect_ones(i,:) = -10;
        end
        for j = 1:size(durations, 2)
            try
               pos_avg(instruction_index, j) = pos_avg(instruction_index, j) + durations(i, j);               
            catch
                pos_avg(instruction_index, j) = durations(i,j);
            end
      
            if durations(i,j) ~= 0
                counters(instruction_index, j) = counters(instruction_index, j)+ 1;
            end
        end
    stimulus_index = stimulus_index +1;
    
    fprintf('trial :\t%d\tstim:\t%d\tinst:\t%d\n', trial_index, stimulus_index, instruction_index);
    else        
        fprintf('skipping fixation cross.\n');
        correct_ones(i,:) = -10;
        incorrect_ones(i,:) = -10;
        
    end
    
    trial_index = trial_index + 1;
end
       
for k = 1:length(pos_avg)
   for i = 1:3
       results(i, k) = pos_avg(i, k) / counters(i, k);
   end
end     
        




