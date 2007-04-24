function ind = getNearest(val,vals)
    min = 9999999;
    for i = 1:length(vals)
        if abs(vals(i)-val)<min
            min = abs(vals(i)-val);
            min_ind = i;
        end
    end
    ind = min_ind;
end