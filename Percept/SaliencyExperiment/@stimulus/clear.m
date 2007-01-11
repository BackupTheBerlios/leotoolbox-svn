function[ new_parameters ] = clear(stimulus, window, parameters)
%
%  The clearscreen function for visual stimuli
% 
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  9/12/2006    Created

switch(stimulus.type)
    case 'picture'
        white = WhiteIndex(window) ;
        darkgray = white/2.2;
        %red = [200 0 0] ;
        %green = [0 200 0] ;
        % blue = [0 0 200];
        %draw gray screen
      
        Screen('FillRect', window, darkgray);
        new_parameters = flip(window, parameters, 'clear screen');
        %Eyelink('Message', 'clear screen');
    otherwise
        error('Function not implemented yet');
end;

