function s = get( bitmap, propName ) 
    
switch propName
    case 'filename'        
    s = [bitmap.filename];
    case 'name'
    s = bitmap.name;
    case 'data'
    s = [bitmap.data];
    case 'path'
    s = bitmap.path;
    otherwise error('No such property');
end;