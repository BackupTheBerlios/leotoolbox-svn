clear all;
commandwindow;
msize=201;
f=1;
if 1
w=rand(msize);
else
mytexdir='plaatjes';
myimgfile=[mytexdir filesep 'konijntjes201gray.jpg' ];
fprintf('Using image ''%s''\n', myimgfile);
w=imread(myimgfile, 'jpg');
end
figure(100);
imshow(w);
wf=fftshift(fft2(double(w)));
% figure
mag=abs(wf);
phase=angle(wf);


if 1
    b=-floor(msize/2):floor(msize-floor(msize/2)-1);
    [x y]=meshgrid(b);
    if 1
        radii=((x.^2+y.^2)^.5);
    else
        radii=sqrt((x.^2+y.^2));
    end

    if 1
        radii=real(radii);
        mi=min(min(radii))
        ma=max(max(radii))
        radii=(radii-mi)/(ma-mi);

	surf(radii)
        mi=min(min(radii))
        ma=max(max(radii))

        %         figure(101);
        %         imshow(real(radii));
        %         colormap(gray);
        %         axis equal
    end
    %   size(radii)
    %   isreal(radii)
    if 1
%         radii=(radii^f);
        radii=1./(radii+.0001);
        mi=min(min(radii))
        ma=max(max(radii))
                radii=(radii-mi)/(ma-mi);

    end
    if 1
        %         mi=min(min(radii));
        %         ma=max(max(radii));
        %         radii2=(radii-mi)/(ma-mi);
        %
        figure(101);
        imshow(radii);
        colormap(gray);
        axis equal
    end
else
    radii=ones(size(mag));
end


% size(mag)
% size(mag.*radii)

% size(exp(i*phase))

% mag=rot90(mag,1);
% m=max(max(mag));
% mag=rand(msize)*m;
mag=ones(msize);
% wf=(mag).*exp(i*phase);

wf=(mag.*radii).*exp(i*phase);


w2=ifft2(ifftshift(wf));

ma=max(max(w2));
mi=min(min(w2));
%
w2=(w2-mi)/(ma-mi);

% figure;
figure(102);
imshow(real(w2));
colormap(gray);
axis equal
%
imdir='plaatjes';
imfile=[imdir filesep 'wolk' num2str(round(rand*999)) '.jpg'];
[s,m,mid] = mkdir(imdir);
imwrite(w2, imfile,'jpg');
fprintf('Saved image file to ''%s''\n', imfile);

