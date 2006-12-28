function landoltC(w, x, y, size, color, background, gap)

% draw a landolt-c with a single gap

rect = CenterRectOnPoint([0 0 size size], x, y);
d0=round((size-1)/2);

rect = [x-d0 y-d0, x+d0+1, y+d0+1];

if size<=5
Screen('FillRect', w ,color, rect); % special case
else
Screen('FillOval', w ,color, rect);
end
% RectSize(rect)

d=round(size/5);

rect = InsetRect(rect, d, d);

if size<=5
Screen('FillRect', w ,background, rect);
else
Screen('FillOval', w , background ,rect);
end
% RectSize(rect)
% paint bar


d1=round((d-1)/2);
d2=d-d1;
d3=round(size/2);

% gap
switch(gap)
    case 'top',
        rect=[x-d1 y-d3-1 x+d2 y];  % we subtract one additional pixel to compensate for rounding errors
    case 'bottom',
        rect=[x-d1 y x+d2 y+d3+1];
     case 'right',
        rect=[x y-d1 x+d3+1 y+d2];
    case 'left',
        rect=[x-d3-1 y-d1 x y+d2];
    case 'vertical',
        rect=[x-d1 y-d3-1 x+d2 y+d3+1];
    case 'horizontal',
        rect=[x-d3-1 y-d1 x+d3+1 y+d2];

    otherwise,
        %nothing
end       
switch(gap)
    case{'top','bottom','right','left', 'horizontal', 'vertical'}
        
        Screen('FillRect', w, background ,rect);
    otherwise,
        %nothing
end


