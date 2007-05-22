function vertlines(xValues, colors, axesHdls, labels)
% function vertLines(xValues, color, axesHdls)
% draws vertical lines (eg. to display events or onsets)
% <xValues>: [X1; X2; ...]
% <colors>:  [r1, g1, b1; r2 g2 b2, ...], 
%            for all lines the same color: specify only one 
% <axesHdl>: handles of axes in which lines are supposed to be drawn

if nargin < 4
    labels =[];
end

if isempty(xValues) | isempty(colors) | isempty(axesHdls)
    return
end

if length(xValues) ~= size(colors,1)
    colors = ones(length(xValues),1)*colors(1:3);
end
    

for ax=1:length(axesHdls)
    axes(axesHdls( ax ));
    for ln=1:length(xValues)
        y= get(gca,'Ylim');
        plot(xValues(ln)*[1 1], y,'.--', 'Color', colors(ln,:)); 
        if ~isempty(labels)
            text(xValues(ln), max(y)*.8, [' ' char(labels(ln))] ,'Color',colors(ln,:));
        end
    end
end



