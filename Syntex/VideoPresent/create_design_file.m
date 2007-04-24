% create movie design matrix
commandwindow
moviedir='/Users/frans/MatlabArchive/OSX/Charmaine/CvdGaag';
breakduration=1;
instruction={'"Beoordeel je gevoel t.a.v. de volgende filmpjes"'};
instruction={'"Imiteer de expressies en beoordeel je gevoel t.a.v. de filmpjes"'};
design = pseudo_randomize_design(1);

myparfile='frans.txt';

fp=fopen(myparfile, 'w');

fprintf(fp,'MOVIE\tMOVIEDIR\tBREAKDUR\tINSTRUCTION\n');

size(design,1)
size(design,2)
first=1;
for i=1:size(design,1)
    for j=1:size(design,2)
        if first==1
            instr=instruction{1};
            first=0;
        else
            instr='No';
        end
        fprintf(fp,'%s\t%s\t%d\t%s\n', design{i,j}, moviedir, breakduration, instr);
    end
end
fclose(fp);

disp('Done');