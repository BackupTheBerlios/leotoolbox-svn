function [ p ] = parameters

  parameters = struct('name', 'value');
  parameters(1).name = 'Timing information';
  time = GetSecs;
  parameters(1).value = struct('time', time);
  
  parameters(2).name = 'Mouse Coordinate information';
  [x, y, buttons] = GetMouse;
  parameters(2).value = struct('x', x, 'y', y,  'buttons', buttons);
  
  parameters(3).name = 'Eyetracker connection information';
  parameters(3).value = 0;
  
  parameters(4).name = 'Flip times of the Screen';
  parameters(4).value = [];
  parameters(5).name = 'Description of the flipping';
  parameters(5).value = [];
  
  parameters(6).name  = 'Logfile';
  parameters(6).value = 0;
  parameters(7).name  = 'Eyetracker filename';
  parameters(7).value = [ '' '.edf'];

  p = parameters;