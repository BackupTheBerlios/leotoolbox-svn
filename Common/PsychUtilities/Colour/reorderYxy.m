function xyY=reorderYxy(Yxy)

% % reorder into x, y, Y, order, should be done in calibration program
% Yxy is a (4) channel by samples, by Yxy (3) matrix.

% for i=1:4
%     temp(:,(i-1)*3+1)=myxyY(:,(i-1)*3+3);
%     temp(:,(i-1)*3+2)=myxyY(:,(i-1)*3+4);
%     temp(:,(i-1)*3+3)=myxyY(:,(i-1)*3+2);
% end

xyY(:,:,1)=Yxy(:,:,2);
xyY(:,:,2)=Yxy(:,:,3);
xyY(:,:,3)=Yxy(:,:,1);
