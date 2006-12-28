function [XYZ, z]=xyYToXYZ(xyY)

% convert between xyY and tristimulus values
% format: xyY=[x y Y] and XYZ=[X Y Z];
% as a bonus you get small z

if xyY(2)==0
    XYZ=[0 0 0];
    z=0;
    return;
end

XYZ(1)=(xyY(1)/xyY(2))*xyY(3);
XYZ(2)=xyY(3);
XYZ(3)=((1-xyY(1)-xyY(2))/xyY(2))*xyY(3);
if sum(XYZ)~=0
    z=XYZ(1)/sum(XYZ);
end