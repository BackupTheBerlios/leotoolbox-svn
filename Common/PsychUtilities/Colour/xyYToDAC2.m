function dac=xyYToDAC(xyY, M_inv, lut, dark)% function dac=xyYtoDAC(xyY,M_inv,lut)% for a CIE input colour[x y Y], returns the DAC value that you have% to use to get that colour% lut is the lookup-table%   01-02-04 jve    first version%   05-02-04 fwc    changed to use newLumToDac rather then find functions.%   09-02-04 fwc    changed name to dacToxyY, replaced XYZToCie by XYZToxyY%                   incorporate dark current correction%	22-09-04 fwc	changed to accept matrices (images)% size(xyY)if size(xyY,2)~=3	fprintf('xyYToDAC2: second dim of xyY should be 3 (=%d)\n', size(xyY,2));end						% default dark value is 0if ~exist('dark', 'var') | isempty(dark)    dark=[0 0 0];end% step 1: calculate X,Y,Z from target x,y,ZXYZ=xyYToXYZ2(xyY);% size(XYZ)% step 1b: calculate X,Y,Z from dark current x,y,ZXYZd=xyYToXYZ(dark);% size(XYZd)% step 1c: calculate XYZa by subtracting dark current XYZ from target XYZXYZa=XYZ-repmat(XYZd,size(xyY,1),1);% size(XYZa)% step 2: calculate Yr, Yg, Yb from X,Y,Z accent valueslum=M_inv*XYZa';% size(lum)% size(lum');lum=lum';% find dac values for these luminances% if 0% 	for j=1:size(lum,1)% 		for i=1:3% 			dac(j,i)=newLumToDac(lum(j,i), lut, i);% 		end% 	end% else	dac=newLumToDac2(lum, lut);% end% size(dac)