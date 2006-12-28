function forbscreentest% test of fORB box input functionsclear all;portid=1; %2 for printer, 1 for serial, 0 for keyboard onlykeyset=2;usekeys=1;usetrigger=0;maxtimetowaitforblanking=0.005;cycles=200000;quitkeyname='esc';quitkey=KbName(quitkeyname);modifierkey=KbName('apple');fprintf('Test program for the fORB response box.\n\n');fprintf('Press apple + ''%s'' to quit the program.\n\n', quitkeyname);forb=newforbinit(portid, keyset, usekeys, usetrigger);if forb.error~=0	fprintf('Error initialising the fORB response box.\n\n');	return;else	blankingPriority=MaxPriority(0,['waitblanking']);	newPriority=MaxPriority(0,['GetSecs'],['KbCheck'],['waitblanking']);	oldPriority=Priority(newPriority);	whichScreen=0; % 0 for main screen	pixelsize=16;	isColor=1;	width=1024;	height=768;	refresh=NaN;	[window, winrect]=setupwindow(whichScreen, width, height, refresh, pixelsize,isColor);	hidecursor;	triggerlogged=0;	triggercount=0;	nvolumes=22;	volumeskip=0;	nslices=25;	istrigger=0;	volumecount=0;	updatescreen=1;	looptime=zeros(cycles,1);	framecount=zeros(cycles,1);		windowstatus=ones(forb.nbits,1);	windowstatus=updatewindow(window, forb, windowstatus, forb.status);	updatetriggers(window, volumecount, triggercount);	forb=newforbScannerCountdown(window, forb, volumeskip, nslices);	triggercount=1; % already waited for the first slice	triggerlogged=1;		count=1;	framecount(count)=0;	%screen(window, 'waitblanking');	looptime(count)=getsecs;	while 1		[keyIsDown,secs,keyCode] = KbCheck;		if keyCode(modifierkey) & keyCode(quitkey)			break;		end			%start=getsecs;		[isbuttondown, istrigger, time, forb]=newforbcheck(forb);		%finish=getsecs;			% tel aantal triggers		if istrigger==1			if triggerlogged==0				triggercount=triggercount+forb.status(forb.trigger);				if triggercount>= nslices % pas op!!				%if mod(triggercount,nslices)==0 % pas op!!					volumecount=volumecount+1;					triggercount=mod(triggercount,nslices);				end				triggerlogged=1;				updatescreen=1;			end		else			triggerlogged=0;		end				count=count+1;			%Priority(tempPriority);		windowstatus=updatewindow(window, forb, windowstatus, forb.status);		if updatescreen==1			updatetriggers(window, volumecount, triggercount);			updatescreen=0;		end				looptime(count)=getsecs;		%checktime(count)=finish-start;		% onderbreek experiment wanneer aantal volumes gehaald is		if volumecount==nvolumes			break;		end	end	Priority(oldPriority);	newforbclose(forb);endshowcursor;SCREEN( 'closeall');looptime=looptime-looptime(1);looptime=looptime*1000;looptime2=looptime(2:count)-looptime(1:count-1);[n,x]=hist(looptime2,40);%n(1)=0;bar(x,n);index=framecount(1:count)>1;i=find(index);size(i)index=framecount(1:count)==0;j=find(index);size(j)%checktime=checktime*1000;%[n,x]=hist(checktime, 40);%n(1)=0;%figure;%bar(x,n);mlooptime=mean(looptime2);maxlooptime=max(looptime2);minlooptime=min(looptime2);fprintf('\nDuration of looptest: %.1f secs.\n', looptime(count)-looptime(1) );fprintf('\nLoop doorlooptime (mean, max, min): %.3f ms, %.3f ms , %.3f ms\n', mlooptime, maxlooptime, minlooptime);FlushEvents('keyDown');	% discard all the chars from the Event Manager queue.fprintf('\nBye!\n\n');%-------------------------------------------function updatetriggers(window, volumecount, triggercount)fontsize=24;font='Courier';oldfont=SCREEN(window,'TextFont',font);oldfontsize=SCREEN(window,'TextSize',fontsize);white=WhiteIndex(window);black=BlackIndex(window);gray=(white+black)/2;rect=SCREEN(window, 'rect');rect(4)=round(rect(4)/8); SCREEN( window, 'FillRect', gray, rect);txt=sprintf('%3d volumes, %4d triggers', volumecount, triggercount);SCREEN(window,'DrawText',txt, fontsize*2,50,white);SCREEN(window,'TextFont',oldfont);SCREEN(window,'TextSize',oldfontsize);%-------------------------------------------function windowstatus=updatewindow(window, forb, windowstatus, buttonstatus)offset=100;rect0=[0 0 100 100];rect0=centerrect(rect0, SCREEN(window, 'rect'));black=BlackIndex(window);for i=1:forb.nbuttons	if xor(buttonstatus(i), windowstatus(i))		switch i			case forb.red,				color=[255 0 0];				rect=offsetrect(rect0, -offset, -offset);			case forb.green,				color=[0 255 0];				rect=offsetrect(rect0, -offset, +offset);			case forb.yellow,				color=[255 255 0];				rect=offsetrect(rect0, +offset, -offset);			case forb.blue,				color=[0 0 255];				rect=offsetrect(rect0, +offset, +offset);		end			if buttonstatus(i)==0			white=WhiteIndex(window);			gray=(white+black)/2;			color2=gray;			windowstatus(i)=0;		else			color2=color;			windowstatus(i)=1;		end		SCREEN(window,'filloval', color2, rect);				SCREEN(window,'frameoval', black, rect, 5, 5);				SCREEN(window,'frameoval', color, rect, 2, 2);			endend		% setupwindowfunction [w, rect]=setupwindow(whichScreen, width, height, hz, pixelSize,isColor)% open a window of particular size and refresh rate% remember some old settings%open screenpixelSizes=SCREEN(whichScreen,'PixelSizes');if max(pixelSizes)<pixelSize	fprintf('Sorry, I need a screen that supports %d-bit pixelSize.\n', pixelSize);	return;endres=NearestResolution(whichScreen,width, height, hz, pixelSize);oldRes=SCREEN(whichScreen,'Resolution');[w,rect]=SCREEN(whichScreen,'OpenWindow',0,[],res);[oldPixelSize,oldIsColor,pages]=SCREEN(w,'PixelSize',pixelSize,isColor);oldBoolean=SCREEN(w,'Preference','SetClutDriverWaitsForBlanking',1);white=WhiteIndex(w);black=BlackIndex(w);gray=(white+black)/2;SCREEN(w,'FillRect',gray);%----------------------------------------------------------------