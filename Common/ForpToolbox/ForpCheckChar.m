function [trigger response time delay goOn]=ForpCheckChar(forp, checkTime)

% USAGE: [trigger response time delay goOn]=ForpCheckChar(forp [, checkTime])
%
% check for trigger from scanner or response from subject
% via Forp response box. Uses Java Based getchar function
% forp is a structure that is initialized in the function ForpInit
% function returns a parameter indicating whether or not to go on
% with the experiment.
% when provided, we only check for a trigger when checkTime has passed,
% to avoid multiple detections of the same trigger
% trigger= trigger or not
% time = trigger or response time
% delay =  delay in return of getchar
% goOn=parameter indicating whether a stop/quit response was given

% note: at the moment, listening is switch off by default after a valid
% response has been obtained. I am not sure this is desired behaviour.
% we could program a flag to specify whether or not we want this.

% history
% 01-06-07  fwc first version extracted from another program
% 03-06-07  fwc modifications

persistent listening

goOn=1; % default: continue with experiment
delay=0; % trigger delay (difference between when.secs returned by GetChar and GetSecs at time of return
time=0; % trigger or response time
trigger=0; % trigger flag
response=[]; % response char

if nargin<2 || isempty(checkTime)
    checkTime=0;
elseif GetSecs < checkTime  % not yet time
    return
end
    
% if it is time to check for a response, we clear the queue and switch on
% char listening
if GetSecs >= checkTime
    if isempty(listening) % when it's time to start checking we'll first clear the queue
        FlushEvents('keydown');
        ListenChar; % start listening
        listening=1; % set flag
    end
end

% check for any key press
done=0;
while CharAvail && done==0
    [mychar when]=GetChar;
    switch(mychar)
        case forp.triggerChar,
            trigger=1;
            done=1;
        case forp.responseChar,
            response=mychar;
            done=1;
        case forp.quitChar,
            goOn=0;
            done=1;
        otherwise,
    end
end

if done==1
    ListenChar(0); % turns char listening off and clears buffer
    listening=[]; % reset flag
    time=when.secs;
    delay=GetSecs-when.secs; % determine getchar's delay
end

