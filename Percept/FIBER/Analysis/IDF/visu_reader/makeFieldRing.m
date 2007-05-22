function ring = makeFieldRing(fix, rad, shoot, stepAngle);
% function ring = makeFieldRing( fixPoint, radius, [overshoot undershoot]);  
%       produces tensor with fields (trapezes) of four points (x,y) 
%       ring(x1..4,y1..4, filedNum) size(ring,3) = no Fields 

% Oliver lindemann (for Visu)

if nargin<4
    stepAngle = 22.5;
end

deg = deg2vec( convertAngles( [ (stepAngle/2):stepAngle:360] )' );
ln = length(deg);
tmpRing(:,:,1) = deg * (rad + shoot(1))  + ones(ln,1) * fix;
tmpRing(:,:,2) = deg * (rad - shoot(2))  + ones(ln,1) * fix;
tmpRing = [tmpRing; tmpRing(1,:,:)]; % to close circles

for m=1:ln
     ring(:,:,m) = [ tmpRing(m:m+1, :, 1);  tmpRing(m+1:-1:m, :, 2)];
end
 


% for m=1:ln
%     plot(ring(:,1,m), ring(:,2,m)); 
% end