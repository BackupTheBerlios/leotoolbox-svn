function[fx fy] = drift_measurement( dataset )
figure
hold on;
ft = 1; fx  = []; fy = [];
for i = 1:length(dataset)
    
    fixations = dataset(i).fixations;
    
    set_avg_x = 0;
    set_avg_y = 0;
    
    for f = 1:length(fixations)
        
        fixation = fixations(f);
        set_avg_x = set_avg_x + fixation.location_x;
        set_avg_y = set_avg_y + fixation.location_y;
        fx(ft) = fixation.location_x;
        fy(ft) = fixation.location_y;
        ft = ft+1;
    end
    set_avg_x = set_avg_x / f;
    set_avg_y = set_avg_y / f;
    fprintf('average fixation location : (\t%d ,\t%d\t)\n', round(set_avg_x), round(set_avg_y));
    
    
end

