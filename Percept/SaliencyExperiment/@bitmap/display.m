function[] = display( bitmap );

data = get(bitmap, 'data');

if (~isempty(data))
    imshow(data);
else
    fprintf('no image data found\n');

    disp(bitmap);
end;
