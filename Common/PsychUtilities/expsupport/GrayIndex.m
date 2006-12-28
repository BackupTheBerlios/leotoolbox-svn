function gray=GrayIndex(w,r)% color=GrayIndex(windowPtrOrScreenNumber,[reflectance])% Returns the CLUT index to produce the specified gray, on a scale of% 0 (black) to 1 (white) at the current screen depth, assuming a% standard color lookup table for that depth. E.g.%      gray=GrayIndex(w,0.3);%      SCREEN(w,'FillRect',gray);% % See BlackIndex, WhiteIndex.%% No compensation is made for the screen's gamma function. This is% just a handy way of picking a few grays for simple text and graphics.% This isn't appropriate for images that need correction for the screen% gamma.% % When the screen is in 1 to 8 bit mode, the Macintosh OS always makes the% first clut element white and the last black. In 16 or 32 bit mode the% clut goes from black to white. These CLUT conventions can be overridden% by SCREEN 'SetClut', which makes a direct call to the video driver,% bypassing the Mac OS, allowing you to impose any CLUT whatsoever.% 10/3/99	dgp Wrote it.% 11/01/03	fwc	added r=0.5 as default% 28/1/05   fwc added rounding of gray value.if ~exist( 'r', 'var' ) | isempty(r)	r=0.5;endgray=round((1-r)*BlackIndex(w)+r*WhiteIndex(w));