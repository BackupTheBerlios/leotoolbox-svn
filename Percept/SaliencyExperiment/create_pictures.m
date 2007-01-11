function[pictures] = create_pictures(bitmaps)
%
% Creates the visual stimuli source screens.
% In this function one can define the placement 
% and number of images to present.
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  06/12/2006    Created
%  20/12/2006    Circular representation added / relative positioning
%  09/01/2007    Added possibility to call present directly on the picture.

index = 1;

number_per_picture = 8;
circular = true;

%ordering = 1:size(bitmaps, 2);
%ordering(1,:) = [1 2 1 1 1 1 1 3];
%ordering(2,:) = [8 7 6 5 4 3 2 1];
%ordering(3,:) = [8 7 6 5 4 3 2 1];
%ordering(4,:) = [8 7 6 5 4 3 2 1];

ws = load('designmatrix');
ordering = ws.d;


if circular == true
    r = 70; % relative radius in percentages
    points = linspace(0, 2*pi, number_per_picture+1);
    xs = r * cos(points);
    ys = r * sin(points);
    for i = 1:number_per_picture
       locations{i} = [xs(i) ys(i)];
    end; 
    start_index = ones(1,number_per_picture);

else
    locations = {[0 0], ... % 1 object
             [-50 0], [50 0], ... % 2 objects, start_index = 2
             [-50 0], [0 0], [50, 0], ... % 3 objects, horizontal, start_index = 4
             [0 -33], [-33 33], [33, 33], ... % 3 objects, triangular, start_index = 7
             [-50 50], [50 50], [-50 -50], [50 -50], ... % 4 objects, start_index = 10
             [-50 50], [50 50], [0 0], [-50 -50], [50 -50], ... % 5 objects, start_index = 14
             [-50 50], [0 50], [50 50], [-50 0], [50 0], [-50 -50], [-50 -50], [50 -50], ... % 8 objects, start_index = 25
             [-50 -50], [-50 0], [-50 50], [50 -50], [50 0], [50 50], ... % 6 objects, start_index = 19
             [-50 -50], [0 -50], [50 -50], ...
             [-50 0],  [50 0], ...
             [-50 50], [0 50], [50 50], ... % 8 objects, start_index = 25
             [-50 50], [0 50], [50 50], [-50 0], [0 0], [50 0], [-50 -50], [-50 0], [50 -50], ... % 9 objects, start_index = 33
            };

    start_index = [1, 2, 4, 10, 14, 19, 25, 33];
end;

rest = mod( size(bitmaps, 2), number_per_picture);
max = size(bitmaps, 2) - rest;

if (rest > 0),
    fprintf('Note: There are %s unused images.\n', num2str(rest));
end

index = 1;

%     for i = 1:number_per_picture:max
%     p = picture;
%     d = ['stimulus picture ' int2str(i)];
%     p = set(p, 'description', d);
%     %fprintf('\n');
%     for j = 0:number_per_picture-1;
% 
%         % use default ordering: image = bitmaps(i + j);
%         o = ordering(index, j +1);
%         image = bitmaps(o);
%         pos = start_index(number_per_picture);
% 
%         %fprintf('locations{pos+j} : [%d %d]\n', locations{pos+j}(1), locations{pos+j}(2));
%         p = add(p, 'bitmap', image, 'location',locations{pos +j} , 'position', 'rel');
%         p = add(p, 'text', '+', 'location', [512 384]);
% 
%     end;
%     pictures(index) = p;
%     index = index+1;
%     end;

for i = 1:60
    p = picture;
    for j = 1:8,
        
        o = ordering(i, j);
        
        image = bitmaps(o);
        p = add(p, 'bitmap', image, 'location',locations{j} , 'position', 'rel');
        % p = add(p, 'text', '+', 'location', [512 384]);
    end;
    pictures(index) = p;
    index =index +1;
end;        
        
        