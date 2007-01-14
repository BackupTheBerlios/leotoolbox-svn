function[stimuli] = designmatrix
%matrix(1:30) = load_bitmaps('/User...house folder');
%matrix(31:60) = load_bitmaps('/User...face folder');

stimuli(1:60, 1:8) = 0;

for i = 1:60
    
    unique_row = false;
    
    while ~unique_row,
        to_fill_index = floor(rand(1,8) * 30) +1;
        house_pos(1:8) = 0;
        while (sum(house_pos)  ~= 4)
          house_pos = round (rand(1,8));
        end
        
        to_fill_index = to_fill_index + house_pos * 30; 

        stimuli(i,:) = to_fill_index;           
        
     if (size(unique(to_fill_index), 2) == size(to_fill_index, 2))
         unique_row = true;
     else
         unique_row = false;
     end;
    end;
end;

