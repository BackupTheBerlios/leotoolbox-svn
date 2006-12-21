function[window, wRect,  parameters] = init_sal_exp( varargin )

%
% initialisation of the saliency experiment
% - global parameter definition 
% - screen setup
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
%   6/12/2006    Created
%  11/12/2006    Debug functionality added

  fprintf('Starting initialisation...\n');
  if nargin >= 1,
      DEBUGPARM = varargin{1}{1};
      fprintf('-- Debug mode -- \n');
      name = 'dummy_experiment1';
  else
      DEBUGPARM=false;
      name = varargin{2};
  end;

  switch(DEBUGPARM)
      case false
          % test the connection and function calls with the eyetracker
          % testcalls;
          EyelinkConn = EYELINK('Initialize');
      case true
          % use dummy eyelink connection;
          EyelinkConn = EYELINK('InitializeDummy');
  end;
  
  Screen('Preference','SkipSyncTests',1)
  screennumber = max(Screen('Screens'));

  [window, wRect] = Screen('OpenWindow', screennumber);
  HideCursor;
  
  white = WhiteIndex(window) ;
  darkgray = white/2.2;
  red = [200 0 0] ;
  green = [0 200 0] ;
  blue = [0 0 200];

  [fp, uniquename] = createlog(name);
  
  %draw gray screen
  
  Screen('FillRect', window, darkgray);
  
  parameters = struct('name', 'value');
  parameters(1).name = 'Timing information';
  time = GetSecs;
  parameters(1).value = struct('time', time);
  
  parameters(2).name = 'Mouse Coordinate information';
  [x, y, buttons] = GetMouse;
  parameters(2).value = struct('x', x, 'y', y,  'buttons', buttons);
  
  parameters(3).name = 'Eyetracker connection information';
  parameters(3).value = EyelinkConn;
  
  parameters(4).name = 'Flip times of the Screen';
  parameters(4).value = [];
  parameters(5).name = 'Description of the flipping';
  parameters(5).value = [];
  
  parameters(6).name  = 'Logfile';
  parameters(6).value = fp;
  parameters(7).name  = 'Eyetracker filename';
  parameters(7).value = [ uniquename '.edf'];
  log('initialize', fp);
  
  parameters = flip(window, parameters, 'initialize');
 
  
  % Start recording of Eyelink
  %el = EyelinkInitDefaults(window);
  
  %EyelinkDoTrackerSetup(el);

  % do a final check of calibration using driftcorrection
  %EyelinkDoDriftCorrection(el);

  WaitSecs(0.1);     
  %Eyelink('OpenFile', 'salexp.eye');
  %Eyelink('StartRecording');

  %eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
  %if eye_used == el.BINOCULAR; % if both eyes are tracked
  %    eye_used = el.LEFT_EYE; % use left eye
  %end
