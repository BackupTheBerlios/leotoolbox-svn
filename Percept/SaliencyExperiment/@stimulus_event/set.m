function s = set( stimulus_event, varargin )
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  9/12/2006    Created

propertyArgIn = varargin;

if (class(stimulus_event) ~= 'stimulus_event')
    msg = ['Invalid class : class of type stimulus required.\nFound class type : ' class(stimulus_event)];
    error(msg);
end
s = stimulus_event;
while length(propertyArgIn) >= 2,

    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);

    switch prop
        case 'name'
            s.name = val;
        case 'index'
            s.index = val;
        case 'duration'
            s.duration = val;
        case 'stimulus'
            s.stimulus = val;
        otherwise
            error('Asset properties: name, index, duration, stimulus')
    end
end
