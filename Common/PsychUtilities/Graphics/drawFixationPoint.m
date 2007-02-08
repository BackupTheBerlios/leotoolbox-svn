function drawFixationPoint(window, fpSize, fpCol);

% draws a fixation point in the center of window
%
% USAGE: drawFixationPoint(window, fpSize, fpCol)
%
% window: window pointer
% fpSize: size of fixation point in percentage of screen width
% fpCol:  color of the fixation point

% made in Tartu


[h v]=WindowSize(window);
fpSize=round(fpSize/100*h);

% % fpSize
% 
% fprintf('*****\nSize of fixation point: %d\n******\n', fpSize);

[x0 y0]=WindowCenter(window);
fpRect=CenterRectOnPoint([0 0 fpSize fpSize], x0, y0);

Screen('FillOval', window, fpCol, fpRect);
