function [lum, message, time]=getLuminance(device)%% USAGE: [lum, message, time]=getLuminance(device)% get a valid luminance reading from the Minolta LS-110 luminance meter% device is a structure with relevant info (set by 'initLuminanceMeter')% 'lum' is luminance reading (-1 in case of failure)% 'message' is additional info provided by meter% 'time' is time of reading (-1 in case of success)%% if the first reading fails, it will try 'device.maxattempts' times% or 'device.maxwaittime' secs whichever comes first.% Part of Minolta toolbox% Send comments and bug reports to: f.w.cornelissen@med.rug.nl%% history% fwc created first version in 2000% 20-01-2002	fwc	simplified code a bit, added waiting as standard option in getluminance%					zeroing of first bit is now part of this code (is this necessary or due to a bug in SERIAL?)% 21-01-2002	fwc	had to first create a string from buffer before converting it to a numberlum=-1;message='No reading';time=-1;if device.port == 0 % simulate reading	lum=device.minsim+rand(1,1) * (device.maxsim-device.minsim);	message='Simulated reading';	time=getsecs;	return;endif device.port == -1 % port is not open	return;endattempt=0;start=getsecs;while getsecs-start< device.maxwaittime  % max time to wait for a proper reading, defined in initLuminanceMeter		% request a measurement by briefly setting the DTR LOW	SERIAL('DTR',device.port,device.low);	WaitSecs(device.dtrlowtime);	SERIAL('DTR',device.port,device.high); % set DTR high again	buffer=SERIAL('Read',device.port);	[n,m]=size(buffer);	if m>=11 & n==1 % then a complete message from the minolta is read (occasionally it may be 2, but we're ignore that)		% the first bit of the bytes read often contains a (randomly assigned?) value of 1		% which causes errors, obviously. Here we set the first bit of each element in 'buffer' to 0		if 1				temp=dec2bin(buffer(1,:),8); % Convert decimal integer to an 8-element binary string			temp(:,1)='0'; % set all first bits to 0			buffer=bin2dec(temp)'; % convert back (Note ' to keep buffer size!		end		lumstr=sprintf('%s',buffer(1,5:9));		lum=str2num(lumstr);		message=sprintf('Mode:''%c'', Unit:''%c'', Calibration:''%c'', Measurement:''%c''', buffer(1,1),buffer(1,2),buffer(1,3),buffer(1,4));		if lum > 0 % success			time=getsecs;			return;		end	end		attempt=attempt+1;	if attempt > 2 & device.printattempts==1		fprintf('Attempt #%d failed.\n', attempt);	end	if attempt >=device.maxattempts 		return;	end	% if the first reading failed, we'll try again after 	% the minimal time between readings has passed	WaitSecs(device.time);end