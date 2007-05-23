cl = 'bob.txt';
filename = [pwd '/' cl]
fid = fopen(filename, 'w')

fprintf(fid,'%s\t%s\t\t\t\t\t\t%s\t\t\t\t\t%s\t\t\t\t\t%s\n','DACs','RED-gun','GREEN-gun','BLUE-gun','WHITE');
fprintf(fid,'\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\n','Y','x','y','Y','x','y','Y','x','y','Y','x','y');
fprintf(fid,'%3i\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\n', [255 ones(1,12)*1.1111]);