function distance = euclid_dist(pA, pB);
% use EUCLID_DIST to calculate the euclidian distances.
%
% function distance = euclid_dist(pA, pB);
%
%  Calculates the euclidian distance between the Points 
%  pA(x1 y2 ...; x1 y2 ...) and pB(x1 y2 ...; x1 y2 ...).
%  if pA just single point pA is reference distance

% Oliver Lindemann, 22.01.2002.


if size(pA,1) == 1 & size(pB,1) > 1
        pA = ones( size(pB,1),1)*pA;
end;

if size(pA,2) ~= size(pB,2) 
       error('wrong vector sizes.');
end

distance = sqrt( sum ( (pA-pB).^2, 2) ); 