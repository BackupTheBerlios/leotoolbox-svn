function [d] = aaveProcessData(matFile) % 2.1


diary('log.txt');

%load raw data
c =clock;
disp(['** aaveProcessData (2)' num2str(c(3)) '.' num2str(c(2)) '.' num2str(c(1)) ' (' num2str(c(4)) ':' num2str(c(5)) 'h) **']);


%filename
[path,filename,ext,ver] = fileparts(matFile);
if isempty(path)
   path = cd;
end

disp('- getting data');
tmp = load([path '\' filename]);
eval(['d = tmp.' filename ';']);
clear tmp;

%%%
% find fixation point after first movement
%%%
fprintf('%s', '  detecting fixations');

firstFixObject = 12;
firstFixX = 13;
firstFixY = 14;
setSize = 15; %1,2
%soundCol = 16;

d.analysed.trials(:,10) = 0;
d.analysed.trials(:,firstFixObject:firstFixY) = nan;

d.analysed.varNames(firstFixObject) ={'gazeOb'};
d.analysed.varNames(firstFixX) ={'gazeX'};
d.analysed.varNames(firstFixY) ={'gazeY'};
d.analysed.varNames(setSize) ={'SetSize'};

fixpoint = d.objects(d.events.noPositions(1)+1,:);


for m=1:size(d.analysed.trials,1)
    % setsize
    d.analysed.trials(m, setSize) =length(d.events.stimuli(m,:)) - length(find(d.events.stimuli(m,:) == 0))-2 ;
    
    fromTo = findtimeStamps(d.eyes.data.tStamps, d.analysed.trials(m,6:7), 1);
    if sum(isnan(fromTo)) == 0
        onSet =   min(find( d.eyes.data.status(fromTo(1):fromTo(2)) == 3)) + fromTo(1)-1;
        offSet=   min(find( d.eyes.data.status(onSet:fromTo(2)) == 4)) + onSet-1;
    else
        offSet = [];
    end
    
    if ~isempty(offSet)
        xy = d.eyes.data.gazeFil(offSet+1,:);
        %adjust trialwise
        tarTime = d.analysed.trials(m,5);
        adjust = d.eyes.data.gazeFil( findTimeStamps(d.eyes.data.tStamps, tarTime, 1), : ) - fixpoint;
        xy = xy - adjust;
        d.analysed.trials(m,firstFixX:firstFixY) = xy;
        

        % find the object field             
        if (length(d.events.noPositions)==1) % only one set size
            theFlds = d.objectFields; 
        else
            if d.analysed.trials(m, setSize) == max(d.events.noPositions) % big one
                theFlds = d.objectFieldsLarge; % or large  depending on setsize
            else
                theFlds = d.objectFields; % or large depending on setsize
            end
        end
        
        for fld = 1:size(theFlds, 3)
            tmp = inside(  complex( xy(1), xy(2) ), complex( theFlds(:,1,fld), theFlds(:,2,fld) ));
            if ~isempty(tmp)
                d.analysed.trials(m,firstFixObject) = fld;
                d.analysed.trials(m,10) = 1;
                break;
            end
        end

    end
    if mod(m, 10) == 1
          fprintf('%s', '.');
    end;
end

disp(' ');
%%%
%saving
%%%
eval([filename ' = d;'])
disp(['- save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);
eval(['save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);

diary off;
