function [trigger response time delay goOn]=ForpKbCheck(forp, checkTime)

% check for trigger from scanner or response from subject
% via Forp response box
% function returns a parameter indicating whether or not to go on
% with the experiment.
% when provided, we only check for a trigger when checkTime has passed,
% to avoid multiple detections of the same trigger
% trigger= trigger or not
% goOn=break or not

goOn=1; % default: continue with experiment
delay=0; % trigger delay (difference between when.secs returned by GetChar and GetSecs at time of return
time=0; % trigger or response time
trigger=0; % trigger flag
response=[]; % response char
%
if nargin==2 && ~isempty(checkTime) && GetSecs < checkTime
    return
end

% check for key press

done=0;

[keyIsDown,tt,keyCode] = KbCheckAny(forp.devices); % check all devices in the list

% check if a key was pressed
if keyIsDown==1
    % test if the user wanted to stop
    if keyCode(forp.quitKey) && keyCode(forp.modifierKey)
        goOn=0;
        done=1;
    elseif keyCode(forp.triggerKey)
        goOn=1; % okidoki
        trigger=1;
        done=1;
    else
        % loop to check for responseKey
        for i=1:length(forp.responseKey)
            if keyCode(forp.responseKey(i))
                response=forp.responseChar{i};
                done=1;
                break
            end
        end
    end
end

if done==1
    time=tt;
end




