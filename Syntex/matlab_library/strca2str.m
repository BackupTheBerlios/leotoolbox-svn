
function out = strca2str(cell_array, delim)
    % converts a cell_array containing strings to one string,
    % delimited by the provided delimiter parameter
    
    one = [];
    for i = 1:size(cell_array,2)
        tmp = cell_array{i};
        tmp = char(tmp);
        one = [one delim tmp];
    end
    if length(one)>0
        one = one(2:end)
    end
    out = one;