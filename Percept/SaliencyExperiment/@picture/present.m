function[ new_parameters ] = present(picture, window, wRect, parameters )
%
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
%  20/12/2006    Relative locations added

x0 = wRect(3) /2;
y0 = wRect(4) /2;

for i = 1:size(picture.elements, 2)
   if (strcmp(class(picture.elements{i}), 'bitmap'))
      element  = get(picture.elements{i}, 'data');
   
      %element_c(:,:, 1) = double(element) ./ 255;
      %element_c(:,:, 2) = double(element) ./ 255;
      %element_c(:,:, 3) = double(element) ./ 255;
    
      width  = size(element, 1);
      height = size(element, 2);
      % relative coordinates to center
      relcoords = picture.locations{i};
      x= relcoords(1); y= relcoords(2);

      if (picture.locationtypes{i} == 'rel')
         x = (x0/100) * x;
         y = (y0/100) * y;
      end;

      location = [x0 - width/2+x, ...
                  y0 - height/2+y, ...
                  x0 + width/2+x, ... 
                  y0 + height/2+y]; 
            
      texture_index = Screen('MakeTexture', window, element); 
      Screen('DrawTexture', window, texture_index, [], location );
      fp = parameters(6).value;
      description = ['stimulus presentation: ' picture.description];
      Eyelink('Message', description);

   else
       % asssume text;
       locations = picture.locations{i};
       element = picture.elements{i};
  
       Screen('TextFont',  window, 'Arial');
       Screen('TextSize',  window, 25);
       Screen('TextStyle', window, 1+2);
       assignin('base', 'w', window);
       Screen('DrawText',  window, element, locations(1), locations(2));   
       fp = ''; description = 'irrelevant';
   end;
end;

new_parameters = flip(window, parameters, description);
log(description, fp);