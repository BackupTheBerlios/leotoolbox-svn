% fORB input functionclear all;port=0; %2 for printer, 1 for serial, 0 for keyboard onlykeyset=2;usekeys=1;usetrigger=0;cycles=200000;quitkeyname='q';quitkey=KbName(quitkeyname);fprintf('Test program for the fORB response box.\n\n');fprintf('Press ''%s'' to quit the program.\n\n', quitkeyname);forb=newforbinit(port, keyset, usekeys, usetrigger);if forb.error~=0	fprintf('Error initialising the fORB response box.\n\n');	return;else		newPriority=MaxPriority(0,['GetSecs'],['KbCheck']);	oldPriority=Priority(newPriority);	stop=0;			looptime=zeros(cycles,1);	%checktime=zeros(cycles,1);			FlushEvents('keyDown');	% discard all the chars from the Event Manager queue.	count=1;	looptime(count)=getsecs;	while stop==0		[keyIsDown,secs,keyCode] = KbCheck;		if keyCode(quitkey)			break;		end			%start=getsecs;		[isbuttondown, istrigger, time, forb]=newforbcheck(forb);		%finish=getsecs;		if isbuttondown==1 % any button pressed?			if forb.status(forb.red)==1  fprintf('Red '); end			if forb.status(forb.green)==1 fprintf('Green '); end			if forb.status(forb.yellow)==1 fprintf('Yellow '); end			if forb.status(forb.blue)==1 fprintf('Blue '); end			fprintf(' button pressed.\n');					end		if istrigger==1 % trigger signal present?			%fprintf('Trigger\n');			stop=1;		end			count=count+1;		looptime(count)=getsecs;		%checktime(count)=finish-start;	end	Priority(oldPriority);	newforbclose(forb);endlooptime=looptime-looptime(1);looptime=looptime*1000;looptime2=looptime(2:count)-looptime(1:count-1);[n,x]=hist(looptime2,40);n(1)=0;bar(x,n);%checktime=checktime*1000;%[n,x]=hist(checktime, 40);%n(1)=0;%figure;%bar(x,n);mlooptime=mean(looptime2);maxlooptime=max(looptime2);minlooptime=min(looptime2);fprintf('\nDuration of looptest: %.1f secs.\n', looptime(count)-looptime(1) );fprintf('\nLoop doorlooptime (mean, max, min): %.3f ms, %.3f ms , %.3f ms\n', mlooptime, maxlooptime, minlooptime);FlushEvents('keyDown');	% discard all the chars from the Event Manager queue.fprintf('\nBye!\n\n');