function[design] = pseudo_randomize_design(n)
%
%  This function creates a pseudo randomized design matrix 
%  consisting of 8 columns, each corresponding to a different emotion.
%  The rows correspond to the number of different persons in
%  the videos. This matrix is duplicated n times
%  
%  If no n is given, n = 3.
%
%  AUTHOR :
%
%  J.B.C. Marsman
%  Neuroimaging Center / Laboratory for Experimental Ophtalmology
%  University Medical Center Groningen
%  The Netherlands
% 
if nargin == 0
    n = 3;
end

design = randomized_block;
for i= 2:n
    block = randomized_block;    
    design(size(design,1)+1: size(design,1)+size(block,1) ,:) = block;
end

%%check for double occurring ones.
for i = 1:size(design, 1)-1    

    f1 = design(i, 8);
    f2 = design(i+1, 1);
    
    if strcmp(f1, f2)
        % swap
        fprintf('swapping row %d\n', i+1);
        temp = design(i+1,1);
        design(i+1, 1) = design(i+1, 2);
        design(i+1, 2) = temp;
    end
end;


function[design] =  randomized_block()
    emotions = {'anger' 'blowing' 'disgust' 'fear' 'happy' 'neutral' 'sad' 'surprise'};
    people = {'AB' 'AD' 'AvD' 'EB' 'GN' 'HV' 'MST' 'SS' 'DA' 'FW' 'KH' 'LP' 'LT' 'MS' 'TR' 'TV'};
    taken_matrix = zeros(length(emotions), length(people));

    for i = 1:16, 

    line = randperm(8);
    
    for j = 1:8
        person_index = round(rand*15) + 1;
        
        while (taken_matrix(j, person_index) == 1)
            person_index = round(rand*15) +1;
        end
            if (person_index < 9)
                gender = 'female';
            else
                gender = 'male';
            end
            taken_matrix(j, person_index) = 1;
            emoline{j} = [gender '/' people{person_index} '/' people{person_index} '_' emotions{line(j)} '.avi'];
        
    end
    design(i, 1:8) = emoline;
end
