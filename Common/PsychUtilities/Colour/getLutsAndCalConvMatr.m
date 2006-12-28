function [M, Mi, luts, dark, prim]=getLutsAndCalConvMatr(varargin)% create LCD display conversion matrix, lut and dark value estimate on% basis of xyY values for different drive values% USAGE: [M, Mi, luts, dark, prim]=getLutsAndCalConvMatr(R,G,B, Gray)% R,G,B = CIE values (x y Y), dac= dac values% or USAGE: [M,Mi,luts,dark, prim]=getLutsAndCalConvMatr(xyY)%  in this case, xyY is a 4 by n rows by 3 (x, y, Y)% array% note: Gray (or channel 4) is not used% comments to Frans W. Cornelissen, email: f.w.cornelissen@med.rug.nl% History% 13-02-04  fwc first version%  what's still missing is the extrapolation of the LUT to full range of%  data so that in can be used with lumToDac (and so). We'll do that%  outside of this routine.thisfile=mfilename;if length(varargin)==1    xyY=varargin{1};elseif length(varargin)==4    [xyY(1,:,:) xyY(2,:,:) xyY(3,:,:) xyY(4,:,:)]=deal(varargin{:});else    error([ 'function  ' thisfile  ' requires 1 or 4 input arguments']);end% create luts (luminance values only)k=length(xyY);luts=(xyY(:,:,3)-repmat(squeeze(xyY(:,1,3)),1,k))'; % subtract dark current contribution% average over all first entries to get best dark value estimatedark=mean(xyY(:,1,:),1);dark=squeeze(dark)';% average a few of the last values to get stable estimate of x,y, and Y% at maximum drive valuesaverage=round(k/10);average=0;xyMax=mean(xyY(:,k-average:k,:),2);xyMax=squeeze(xyMax);size(xyMax);% create matrix with (corrected) xyz values at maximum drive valuep=[ xyMax(1,1) xyMax(2,1) xyMax(3,1);    xyMax(1,2) xyMax(2,2) xyMax(3,2)];% calculate third row   for i=1:3    p(3,i)=1-p(1,i)-p(2,i);endprim=p;% calculate conversion matrixM=[p(1,1)/p(2,1) p(1,2)/p(2,2) p(1,3)/p(2,3);    1 1 1;    p(3,1)/p(2,1) p(3,2)/p(2,2) p(3,3)/p(2,3) ];% and inverseMi=inv(M);