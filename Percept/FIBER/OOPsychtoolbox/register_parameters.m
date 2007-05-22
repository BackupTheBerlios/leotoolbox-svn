function[parameters_updated] = register_parameters(parameters)
%
%  register time and mouse dynamics and other interesting things
%  like gaze ..
%
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

now = GetSecs;
[x,y, buttons] = GetMouse;
    
timeslots  = parameters(1).value;
mouseslots = parameters(2).value;
    
indices = size(timeslots)
index = size(timeslots, 2) + 1;

timeslots(index).time = now;
mouseslots(index).x = x;
mouseslots(index).y = y;
mouseslots(index).buttons = buttons;
    
parameters(1).value = timeslots;
parameters(2).value = mouseslots;
parameters_updated = parameters;
