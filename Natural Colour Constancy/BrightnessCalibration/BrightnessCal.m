% simple luminance calibration example using interp1

lutfile='somelcd.txt';

luts=textread(lutfile, '', 'delimiter','\t', 'headerlines', 1);

dacs=luts(:,1);
lums=luts(:,11)

pattsz=500;

mylums=rand(pattsz,pattsz)*100+1; % we can't get values below dark current luminance.
%  I am simply adding 1 here. 

ts=GetSecs;
mydacs=round(interp1(lums, dacs, mylums));
te=GetSecs;
fprintf('\nTime to find %d lum values was: %.2f ms.\n', pattsz*pattsz, (te-ts)*1000);
% size(mydacs)


