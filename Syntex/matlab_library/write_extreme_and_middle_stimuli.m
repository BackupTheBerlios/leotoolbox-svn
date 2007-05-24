function write_extreme_and_middle_stimuli(txtfilename,nPerSegment)
    %fid = fopen(txtfile);
    data = load_data(txtfilename);
    
    fileparts = strsplit(txtfilename, '/')
    filename = fileparts(end,:)
    filenames = strsplit(filename,'.')
    fileroot = filenames(1,:)

    
    k = 0;
    for i = 1 : size(data,2)
        regel = data{i}
        if ~isempty(regel)
            regel = regel{1};
            k = k + 1;
            arr = strsplit(regel,',');
            bestand = arr(1,:);
            score = arr(2,:);
            stimuli{k}=bestand;
            scores(k)=str2num(score);
            
        end
    end
    
    
    fidpos = fopen([fileroot '_pos.txt'],'w');
    fidneu = fopen([fileroot '_neu.txt'],'w');
    fidneg = fopen([fileroot '_neg.txt'],'w');
    
    
    [scores,IDX] = sort(scores);
    ind = 0;
    for i = 1:nPerSegment
        ind = ind + 1;
        indx = IDX(i);
        selection{ind} = stimuli{IDX(i)};
        fprintf(fidneg, '%s\n',[selection{ind}]);
        
    end
    %eerste = size(selection)
    
    
    for i = floor((length(IDX)-nPerSegment)/2+1):floor((length(IDX)+nPerSegment)/2)
        ind = ind + 1
        i_is = i
        selection{ind} = stimuli{IDX(i)};
        fprintf(fidneu, '%s\n',[selection{ind}]);

    end
    %tweede = size(selection)
    
    
    for i = length(IDX)-nPerSegment+1:length(IDX)
        ind = ind + 1;
        selection{ind} = stimuli{IDX(i)};
        fprintf(fidpos, '%s\n',[selection{ind}]);

    end
    %derde = size(selection)
    
    fclose(fidpos);
    fclose(fidneu);
    fclose(fidneg);
    
    
    
    
    

    
    