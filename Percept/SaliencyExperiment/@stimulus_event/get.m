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
    otherwise error('No such property');
end;