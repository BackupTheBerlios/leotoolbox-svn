function[ parameters ] = draw_in_buffer(stimulus, window, wRect)
%
%  Present the stimulus, without duration limits, 
%  mainly for debug purposes.
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  11/12/2006    Created

%%%  parameters have to be passed on ? 


for s = 1:size(stimulus,2)
    
    data = stimulus(s).data;
    
    switch class(data)
        case 'picture'
            parameters = draw_in_buffer(data, window, wRect);
        otherwise
            error('Not implemented yet.');
    end;


end;
    
