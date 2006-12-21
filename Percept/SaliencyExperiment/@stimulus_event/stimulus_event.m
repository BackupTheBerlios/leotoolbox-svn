function s = stimulus_event( varargin )
%
%  Constructor for a screen / display of a stimulus
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created

s.name = 'default stimulus_event';
s.index = '';
s.duration = 2000;
s.stimulus = stimulus; 

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,

    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);

    switch prop
        case 'stimulus'
            if (size(val, 2) == 1)
                if (class(val) == 'stimulus')
                    s.stimulus = val;
                else
                    error('Cannot create stimulus-event from non-stimulus object');
                end;
            else
              error('Cannot create stimulus-event from multiple stimuli');
              end;
        case 'duration'
            s.duration = val;
        case 'name'
            s.name = val;
        case 'index'
            s.index = val;
        otherwise
            error('Asset properties: name, index, duration, stimulus')
    end
end
        
% stimulus can be of type { picture, sound, nothing, movie }
if (nargin == 1)
    if (size(varargin{1}, 2) == 1)
        if (class(varargin{1}) == 'stimulus')
                    s.stimulus = varargin{1};
        else
        error('Cannot create stimulus-event from non-stimulus object');
        end;
    else
        error('Cannot create stimulus-event from multiple stimuli')
    end;
end;
s = class(s, 'stimulus_event');

