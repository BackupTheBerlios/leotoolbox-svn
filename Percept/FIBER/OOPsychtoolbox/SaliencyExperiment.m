function[results] = SaliencyExperiment( varargin )

%  
%  contains the main loop for the experiment
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


% load the image database
images = load_bitmaps;
pictures = create_pictures(images);

% initialise the screen and other parameters
[window, wRect, parameterlist] = init_sal_exp (varargin );

stimuli = create_stimuli( pictures );

%set default durations to 3000 ms.
durations(1:size(stimuli,2)) = 2000;  
stimuli_events = create_events(stimuli, durations);

%run the experiment
parameterlist = present(stimuli_events, window, wRect, parameterlist);


%clean up and release the results
cleanup( parameterlist );
finalize( 'All' );
results = parameterlist;

