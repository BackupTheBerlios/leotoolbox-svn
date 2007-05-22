function[ trials ] = hit_test(trials, run, starting_pos, area_centers, radius)
%  Checks whether location [x,y] is inside 
%  any of the given circular areas; 
%  currently non-overlapping circles are only implemented
%  works for 7 areas..
% 
%  SYNOPSIS : hit_test ( trials, run, starting_pos, area_centers, radius ) 
%
%  if only trials are given, run = 1, radius = 110; 
%  if trials, run and starting_pos are given, area_centers = default
%  and radius = 110
%
%
%  AUTHOR :
%
%  J.B.C. Marsman
%  Neuroimaging Center / Laboratory for Experimental Ophtalmology
%  University Medical Center Groningen
%  The Netherlands
% 

if nargin == 0
    %% testing phase
   [a, area_centers] = areas_of_interest(1024, 768, 0, 6);
   radius = 110;
   test_image = zeros(1024, 768);
   radius = 110;
   
   for x = 1:1024
       for y = 1:768
          for aoi = 1:length(area_centers)
             area_x = area_centers(aoi).x;       
             area_y = area_centers(aoi).y;
             solution = radius^2;
             if (  (area_x - x)^2 + (area_y - y)^2 < solution )
                test_image(x,y) = aoi;
             end;
          end;
       end;
   end;       
   trials = test_image; 
   imshow(test_image);
end
   
if nargin ==1
  %% assume presentation screen : 1024 x 768
  [a, area_centers] = areas_of_interest(1024, 768, 0);
  radius = 110;
  starting_pos = 60;
  run = 1;
end

if nargin == 3
    %% trials, run and starting_pos are defined earlier
  [a, area_centers] = areas_of_interest(1024, 768, 0);
  radius = 110;
end

hitdata = struct('trial', [], 'areas', area_centers, 'hits', []);

%% for every trial, ...
for t= 1: length(trials)
    hitcounter =0   ;
    trialdata = trials(t);    
    hitdata(t).trial = trialdata;
    
    %% check every fixation, ...
    for i = 1: length(trialdata.fixations)
        x = trialdata.fixations(i).location_x;
        y = trialdata.fixations(i).location_y;
        
        hit{1} = -1;  %% area category    
        hit{2} = {'unlabeled'}; %% area label
        hit{3} = 0; %% value assigned to group of areas
        hit{4} = 0;
        %% whether it falls inside any defined area of interest.
        for aoi = 1:length(area_centers)

          area_x = area_centers(aoi).x;       
          area_y = area_centers(aoi).y;

          solution = radius^2;
          if (  (area_x - x)^2 + (area_y - y)^2 < solution )
            hit{1} = aoi;
            hitcounter = hitcounter +1;
            %fprintf('aoi :\t%d\n', aoi);
          end;
        end;
        
        trials(t).fixations(i).hit = hit;   

    end;
    if t == 60
    fprintf('%d\t%d\t%d\n', hitcounter, length(trials(t).fixations), t);
    end
end;