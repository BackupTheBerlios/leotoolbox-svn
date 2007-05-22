function[pruned] = remove_around_blinks(data, threshold_ms)
%%
%
% Removal of fixations smaller than a given threshold around blinks
%

for i = 1:length(data)

    blinks = data(i).blinks;
    
    for j = 1:length(blinks);
    
        blink_index = blinks(j).index;
    
        %look for events with index -1, index -2, index +1 and index +2
        
    end
end;