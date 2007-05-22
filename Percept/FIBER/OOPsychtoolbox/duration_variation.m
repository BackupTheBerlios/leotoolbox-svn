function[events] = duration_variation(events)

file = load('/Users/marsman/Documents/Experiments/070419_houses_versus_faces/Stimuli/durations.mat');
durations = file.stim_durations;


for i = 1: size(events, 2)
    events(i) = set(events(i), 'duration', durations(i));
end
    


%
%
%
%durations = round((exp(-linspace(0, 10))*10  + 8)*1000);
%split = 20;
%
%for i = 1:100
%    index = round(rand * split) + 1;

%    stim_durations(i) = durations(index);
%end;

%mean(stim_durations)