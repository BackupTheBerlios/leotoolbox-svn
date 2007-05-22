function s = get( stimulus, propName ) 
    

switch propName
    case 'type'        
        s = stimulus.type;
    case 'data'
        s = stimulus.data;
    case 'content'
        s = stimulus.data;

    otherwise error('No such property');
end;