function out = match_ud(str, list)

    out = false;
    i = 1;

    while i <= length(list)
        
        if strcmp(str, list(i).name)
            out = true;
            break;
        end
        i = i + 1;
    end
    
end
