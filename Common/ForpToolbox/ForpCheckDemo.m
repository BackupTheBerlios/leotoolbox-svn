% ForpCheckDemo

% demonstrates use of ForpCheckChar functie

clear all
commandwindow;

% initialize forp structure
forp=ForpInit;
% forp=ForpInit(triggerChar, responseChar, quitChar);  % in case you want
% to set a different (or limited) set, you can specify this here, e.g.
% forp=ForpInit('5', {'a', 'b'}, 'S');

checkDelay=0.005; % optional, specify the next time to check for a response/trigger after a valid trigger/response

disp(['start ' mfilename])

checkTime=GetSecs; % now, could be another moment later on
delta=0;
prev=0;
it=0;
lt=zeros(100000,1); % pre-allocate array with looptimes
while 1

    it=it+1;
        [trigger response time delay goOn]=ForpCheckChar(forp, checkTime);
    
    lt(it)=GetSecs;
    if trigger>0 || ~isempty(response)
        delta=time-prev;
        fprintf('%d\t%d\t%s\t%.2f\n', it, trigger, response, delta);
        checkTime=time+checkDelay; 
        prev=time;
    end

    % quit loop when indicated
    if ~goOn
        break
    end

    WaitSecs(0.005); % wait a bit, or do something else
    
end

% calculate mean looptime
lt=lt(find(lt>0));
lt=diff(lt);
melt=mean(lt);

fprintf('Mean loop time: %f\n', melt);
disp(['end ' mfilename])
