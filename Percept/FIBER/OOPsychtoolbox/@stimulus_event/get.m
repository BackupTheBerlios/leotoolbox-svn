function s = get( stimulus, propName ) 
    
s.base = '';
s.name = '';
s.index = '';
s.duration = [];
s.category = '';
s.content = 0;

switch propName
    case 'base'        
        s = stimulus.base;
    case 'name'
        s = stimulus.name;
    case 'index'
        s = stimulus.index;
    case 'duration'
        s = stimulus.duration;
    case 'content'
        s = stimulus.content;
    case 'stimulus'
        s = stimulus.stimulus;
    case 'trigger'
        if ((stimulus.wait_for_trigger_before == true) && (stimulus.wait_for_trigger_after == true))
            s = 'both';
        elseif (stimulus.wait_for_trigger_after == true)
            s = 'after';
        elseif (stimulus.wait_for_trigger_before == true)
            s = 'before';
        else 
            s = 'none';
        end
    otherwise error('No such property');
end;