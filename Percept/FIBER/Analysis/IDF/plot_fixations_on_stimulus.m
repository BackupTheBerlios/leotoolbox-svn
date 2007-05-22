function[] = plot_fixations_on_stimulus( image , trial )

fixations = trial.fixations;
stimulus_path = '/Users/marsman/Documents/Experiments/070115_houses_versus_faces/Stimuli/Presented/run1/';

filename = [stimulus_path image];
stimulus = rgb2hsv(imread(filename));
stimulus = stimulus(:,:,3); %% hsv - only select value
stimulus = stimulus ./ max(stimulus(:)) * 100;
figure;

offset = fixations(1).start;

for f = 1:length(fixations)
   fixation = fixations(f);
   
   
   duration = fixation.duration;
   
   y = repmat(fixation.location_x, 1, duration);
   x = repmat(fixation.location_y, 1, duration);
   z = (fixation.start - offset):(fixation.start - offset + duration -1);
   plot3( x,y,z, 'ro'), hold on;
end;


ylim([0 1024]);
xlim([0 768]);
grid on;
xlabel('X')
ylabel('Y')
zlabel('Z')
x = fixation.start - offset + duration

plane = repmat(x, 1024, 768);



%surface('XData',[1:size(plane,2)],...
%        'YData',[1:size(plane,1)],...
%        'ZData',plane,...
%        'CData',plane, ...

surface(plane, rot90(stimulus), ...
        'FaceColor', 'texturemap', ...
        'EdgeColor', 'none', ...
        'CDataMapping', 'direct');
    
alpha(.5);        
colormap('gray');

