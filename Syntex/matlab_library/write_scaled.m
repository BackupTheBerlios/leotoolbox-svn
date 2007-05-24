function write_scaled(txtfilename)
    fileparts = strsplit(txtfilename, '/')
    filename = fileparts(end,:)
    filenames = strsplit(filename,'.')
    fileroot = filenames(1,:)
    
    tekst = load_data(txtfilename);
    %t1 = tekst{1}
    %t301 = tekst{301}
    %emp = isempty(t301)
    sz = size(tekst,2);
    k = 0;
    for i = 1: size(tekst,2)
        if ~isempty(tekst{i})
            k = k + 1;
            tmp = tekst{i}{1};
            arr = strsplit(tmp,',');
            bestanden{k} = arr(1,:);
            score = arr(2,:);
            scores{k} = score;
            numscores(k) = str2num(score);
            
            
            
        end
    end    
    scaledscores = normalize_dbls(numscores,100);
    fid = fopen([fileroot '_scaled.txt'],'w');
    
    for j = 1:k
        fprintf(fid, '%s\n',[bestanden{j} ',' scores{j} ',' num2str(scaledscores(j))]);
    end
    
    
    
    
    
    
    