function [ areas, centers ]= areas_of_interest(screenwidth, screenheight, plotting, number_per_picture)
%
% This script defines the areas where object reside in a visual stimulus
% 
% Adapt this to your stimuli. 
%

if (nargin == 0)
    screenwidth = 1024;
    screenheight = 768;
    plotting = 1;
end

if (nargin <= 3)
    number_per_picture = 8;
end
%% mirrored image!!
%template = imread('/Users/marsman/Documents/Experiments/070115_houses_versus_faces/Stimuli/Presented/run1/02-run1-starting stimulus event 1-2.jpg');

areas   = struct('x', [], 'y', []);
centers = struct('x', [], 'y', []);

%% define global centers for each aoi
rx = .35 * screenwidth;
ry = .35 * screenheight;
points = linspace(0, 2*pi, number_per_picture+1);
xs = rx * cos(points) + screenwidth / 2; 
ys = ry* sin(points) + screenheight / 2;
%template = imrotate(template, 180);

if plotting
    hold on;
    %image(template);
    plot(xs, ys,'r--');
end;

for aoi = 1:number_per_picture
  centers(aoi).x = xs(aoi);
  centers(aoi).y = ys(aoi);

  %% define aoi
  r = 110;
  spacing = 100;
  points = linspace(0, 2*pi, spacing);
  
  aoi_xs = r * cos(points) + xs(aoi);
  aoi_ys = r * sin(points) + ys(aoi);

  if plotting
      plot(aoi_xs, aoi_ys);
  end
  
  areas(aoi).x = aoi_xs;
  areas(aoi).y = aoi_ys;

end;

if plotting
    xlim([0 screenwidth]);
    ylim([0 screenheight]);
    hold off;
end;