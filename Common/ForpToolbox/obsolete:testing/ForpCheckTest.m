% test forpCheck


clear all
commandwindow;

% global forp
forp=ForpInit;
% forp=ForpInit('5');
% frop=ForpInit(triggerChar, responseChar, quitChar);  % in case you want
% to set a different (or limited) set

disp(['start' mfilename])
forp

checkTime=GetSecs;
dTrigger=GetSecs;
prevTrigger=0;
it=0;
lt=zeros(100000,1);
while 1

    it=it+1;
    if 0
        [trigger response time delay goOn]=ForpKbCheck(forp, checkTime);
    elseif 1
        [trigger response time delay goOn]=ForpCheckChar(forp, checkTime);
    else
        trigger=0;
        response=[];
        goOn=1;
        [keypressed, time]=ForpCheck;
        switch(keypressed)
            case forp.triggerChar,
                trigger=1;
            case forp.responseChar,
                response=keypressed;
        end
        [keyIsDown,tt,keyCode] = KbCheckAny(forp.devices); % check all devices in the list

        % check if a key was pressed
        if keyIsDown==1
            % test if the user wanted to stop
            if keyCode(forp.quitKey) && keyCode(forp.modifierKey)
                goOn=0;
                time=tt;
            end
        end
    end
    
    lt(it)=GetSecs;
    if trigger>0 || ~isempty(response)
        dTrigger=time-prevTrigger;
        fprintf('%d\t%d\t%s\t%.1f\n', it, trigger, response, dTrigger);
        checkTime=time+.00005;
        prevTrigger=time;
    end

    if ~goOn
        break
    end

    WaitSecs(0.005);
    
end

lt=lt(find(lt>0));
lt=diff(lt);
melt=mean(lt)
malt=max(lt)
milt=min(lt)
hist(lt);
disp('klaar');