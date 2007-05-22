function [trials] = bin(area_centers, radius, trials)

for i = 1: length(trials)
    
    por_x =  trials(i).data{6};
    por_y =  trials(i).data{7};
    
    area = hittest(por_x, por_y, area_centers, radius);
    trials(i).data{8} = area;
end;