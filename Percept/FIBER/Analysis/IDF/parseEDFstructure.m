function[images] = parseImage(edf_structure)

l = length(edf_structure);

images = struct('image', '', 'orientation', 0, 'fixations', [], 'onset' , 0);

    
subject = getfilebasename(edf_structure(1).filename);

for i = 1:l
   
    trial = edf_structure(i);
    userevents = trial.userevents;
    
    ul = length(userevents);
    for j = 1:ul
        u = userevents(j);
        u.description;
        if (length(u.description) > 4)
            
            if (strcmp('IMAGE', u.description(1:5)))
               sl = length(u.description);
               if (strcmp('ORIENTATION', u.description(7:17)))
                 orientation = u.description(18:sl);
                images(i).orientation = str2num(orientation);
               elseif (strcmp('RECT', u.description(7:10)))
               else
                imagename = u.description(6:sl);
                images(i).image = imagename;
                images(i).fixations = trial.fixations;
               end
            end;
        end;
    end    
end
path = '/Users/marsman/Documents/Programming/Matlab/leotoolbox/Percept/NaturalGazeExp/';
radius = 20;

drawImages(path, subject, images, radius);
%getImagePatches(path, subject, images, radius);
%exportFixations(path, images, radius);


%% ---------------- export functions

function drawImages(path, subject, images, radius)

screennumber = max(Screen('Screens'));
Screen('Preference','SkipSyncTests', 0);
[window, wRect] = Screen('OpenWindow', screennumber);
Screen('TextStyle', window, 1);


for i = 1 : length(images)
    
   filename = [path images(i).image];
   angle    = images(i).orientation;
   fixations = images(i).fixations;
   
   imdata = imread(filename);
   filename
   [w h]   = WindowSize(window);
   
   [ih iw, c] = size(imdata);
   textRect = [0 0 iw ih];
   
   centeredRect = CenterRectOnPoint( textRect, w/2, h/2);
   
   tex = Screen('MakeTexture', window, imdata);
   Screen('DrawTexture', window,  tex, [], centeredRect, angle);

   for j = 2:min(6, length(fixations))
        fixation = fixations(j);  
        center = [(fixation.location_x-3) (fixation.location_y-3) (fixation.location_x+3) (fixation.location_y+3)];
        coord = [(fixation.location_x - radius) (fixation.location_y - radius) (fixation.location_x + radius) (fixation.location_y + radius)];
        Screen('DrawArc', window, [ 255 0 0 ], coord, 0, 360);   
        Screen('DrawArc', window, [ 255 0 0 ], center, 0, 360);
        Screen('DrawText', window', num2str(j-1) , coord(3)- (radius/2)+5, coord(4) - (radius/2), [255 0 0 ]);        

   end
   Screen('Flip', window);
   output = Screen('GetImage', window, centeredRect);
   imagename = getfilebasename(filename);

   if ~exist(['/Users/marsman/Desktop/fixationplots/' subject], 'dir')
       mkdir(['/Users/marsman/Desktop/fixationplots/' subject]);
   end

   filename = ['/Users/marsman/Desktop/fixationplots/' subject '/' imagename '_' num2str(angle) '.jpg'];
   
   imwrite(output, filename, 'JPEG');

end


function getImagePatches(path, subject, images, radius)

screennumber = max(Screen('Screens'));
Screen('Preference','SkipSyncTests', 0);
[window, wRect] = Screen('OpenWindow', screennumber);


for i = 1 : length(images)
    
   filename = [path images(i).image];
   angle    = images(i).orientation;
   fixations = images(i).fixations;
   
   imdata = imread(filename);

   [w h]   = WindowSize(window);
   
   [ih iw, c] = size(imdata);
   textRect = [0 0 iw ih];
   
   centeredRect = CenterRectOnPoint( textRect, w/2, h/2);
   
   tex = Screen('MakeTexture', window, imdata);
   Screen('DrawTexture', window,  tex, [], centeredRect, angle);
   Screen('Flip', window);


   imagename = getfilebasename(filename);

   if ~exist([path 'analysis/' imagename], 'dir')
       mkdir([path 'analysis/' imagename])
   end
   if (~exist([path 'analysis/' imagename '/' subject], 'dir'))
       mkdir([path 'analysis/' imagename '/' subject]);
   end;
   
   for j = 1:length(fixations)
        fixation = fixations(j);  
        latency = fixation.start - images(i).onset
        
        coord = [(fixation.location_x - radius) (fixation.location_y - radius) (fixation.location_x + radius) (fixation.location_y + radius)];
        
        patch = Screen('GetImage', window, coord);
        outputfile = [path 'analysis/' imagename '/' subject  '/' num2str(j) 'r_' num2str(radius) '_a_' num2str(angle) '.jpg'];
        %imwrite(patch, outputfile, 'JPEG');
   end
end


function exportFixations(path, images, radius)


for i = 1 : length(images)
    
   filename = [path images(i).image];
   angle    = images(i).orientation;
   fixations = images(i).fixations;
   
   imagename = getfilebasename(filename);
   
   if ~exist([path 'analysis/' imagename], 'dir')
      mkdir([path 'analysis/' imagename])
   end

   output = fopen([ path 'analysis/' imagename '/fixations.txt'], 'w');
   fprintf('subject\tfixation_number\tx_pos\ty_pos\n');

   for j = 1:length(fixations)
        fixation = fixations(j);  
        latency = fixation.start - images(i).onset
        
        x = fixation.location_x;
        y = fixation.location_y;
        
        fprintf('%s\t%d\t%d\t%d\n', subjectname, fixation); 
   end
end


function[base] = getfilebasename(filename)    
  %% extract path
  slashes = strfind(filename, '/');
  lastslashindex = slashes(length(slashes));

  file = filename(lastslashindex+1:length(filename));
  

  %extract extension 
  dots = strfind(file, '.');
  if (~isempty(dots))
    base = file(1:dots(1)-1);
  else
    base = file;
  end;
  

