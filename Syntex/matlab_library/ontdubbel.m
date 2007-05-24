function out = ontdubbel(dblArray)
    tmp = [];
    
    for i = 1:size(dblArray,1)-1
        %dbls = dblArray(i);
        use_this = true;
        for j = i+1:size(dblArray,1)
            if dblArray(i,:)==dblArray(j,:)
                disp = [i,j]

                use_this = false;
            else
                
            end
        end
        if use_this
            tmp = [tmp;dblArray(i,:)];
        end
    end
    out = tmp;
end
            