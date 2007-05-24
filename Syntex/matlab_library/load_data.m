function contents = load_data(filename)
%fid = fopen('props_textrs.txt');
fid = fopen(filename);
i = 0;
while ~feof(fid)
    i = i + 1;
    tmp = textscan(fid,'%s',1);
    contents{i} = tmp{1};
end

fclose(fid);