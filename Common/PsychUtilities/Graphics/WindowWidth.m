function width = windowwidth(window)% width = windowwidth(window)%% Returns a window's width%% 26/03/2001 fwc based on rectwidth.mif nargin~=1	error('Usage:  width = windowwidth(window)');endrect=SCREEN(window,'Rect');width = rect(RectRight) - rect(RectLeft);