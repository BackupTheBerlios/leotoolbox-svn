clear all;lutfiledir='lutfiles';par.lutfilename='dummyxyzz';par.polyorder=3;par.guns=4;par.maxdac=255;newdac=0:par.maxdac;  % one entry for each dac valuefilename=[filesep lutfiledir filesep par.lutfilename '.cal' ];%[par.olddac, par.cal(:,1), par.cal(:,2), par.cal(:,3), par.cal(:,4)]=textread(filename, '%f\t%f\t%f\t%f\t%f', 'headerlines', 1 );[par.olddac(1,:), par.cal(1,:), par.cal(2,:), par.cal(3,:), par.cal(4,:)]=textread(filename, '%f\t%f\t%f\t%f\t%f', 'headerlines', 1 );for i=1:par.guns	[p,s] = polyfit(par.olddac,par.cal(i,:),par.polyorder);	newlut(i,:)=polyval(p, newdac);end[n,m]=size(newlut);%return;% correct for any increases at low dac valuesfor c=1:n	for r=m-1:-1:1		if newlut(c,r+1) < newlut(c,r) | newlut(c,r) < par.cal(c,1)			% replace data by linearly extrapolating between previous value and first measured value			newlut(c,1:r+1)=linspace(par.cal(c,1), newlut(c,r+1), r+1);				break;		end	endend% save the new lut datafilename=[filesep lutfiledir filesep par.lutfilename '.lut3' ];fp=fopen( filename, 'w');[n,m]=size(newlut);fprintf(fp, 'DAC\tRED\tGREEN\tBLUE\tWHITE\n');for r=1:m	fprintf(fp,'%d', newdac(r));	for c=1:n		fprintf(fp,'\t%f', newlut(c,r));	end	fprintf(fp,'\n');endfclose(fp);