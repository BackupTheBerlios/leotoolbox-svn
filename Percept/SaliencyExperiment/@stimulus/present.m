function[ parameters ] = present(stimulus, timeout, varargin)
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

cost = 403.7;

if (nargin == 1)
    timeout = 3;
end;
if (nargin > 2)
    %use predefined Screen parameters
    window = varargin{1};
    wRect = varargin{2};
    parameters = varargin{3};
else
    %create new Screen buffer
    Screen('Preference','SkipSyncTests',1)
    screennumber = max(Screen('Screens')); 
    [window, wRect] = Screen('OpenWindow', screennumber);
    
    try
        parameters = varargin{1};
    catch 
        parameters = -1;
    end;
end;

for s = 1:size(stimulus,2)
    
    data = stimulus(s).data;
    
    switch class(data)
        case 'picture'
            parameters = present(data, window, wRect, parameters);
        otherwise
            error('Not implemented yet.');
    end;

if (strcmp(class(parameters), '') == 0)
    pause;
else
    WaitSecs(timeout - 0.0200);
    parameters = clear(stimulus, window, parameters);
end;

end;
    
% development phase functionality : finalize screen after 'normal' present
% call
if (nargin == 1)
    finalize('Screen');
end;
