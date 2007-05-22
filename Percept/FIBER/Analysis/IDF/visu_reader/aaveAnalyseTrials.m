function aaveAnalyseTrials( processedMatDataFile )

% analyses data trialwise for SPA1
% Oliver Lindemann 


%logging on
diary('log.txt');

%load raw data
c =clock;
disp(['** AnalyseTrials ' num2str(c(3)) '.' num2str(c(2)) '.' num2str(c(1)) ' (' num2str(c(4)) ':' num2str(c(5)) 'h) **']);

%filename
[path,filename,ext,ver] = fileparts(processedMatDataFile);
if isempty(path)
   path = cd;
end

disp(['- getting data: ' filename] );
tmp = load([path '\' filename]);
eval(['d = tmp.' filename ';']);
clear tmp;

%varNames 
d.analysed.varNames(11) ={'fixed object pos'};
d.analysed.varNames(12) ={'fix_X'};
d.analysed.varNames(13) ={'fix_Y'}; % all from aaveProcessData

d.analysed.varNames(14) ={'RT'};
d.analysed.varNames(15) ={'error type'};
d.analysed.varNames(16) ={'noDist'};


fprintf('%s','- analysing trialswise');

d.analysed.trials(:,14:16) = nan;
tr = d.analysed.trials;
noTrials = size(tr,1);
stimOn  = 6;
stimOff = 7;


for m =1:noTrials

     %from & to
     from = findTimeStamps(d.eyes.data.tStamps, tr(m, stimOn) ,1);
     to   = findTimeStamps(d.eyes.data.tStamps, tr(m, stimOff) ,1);
     
     st = d.eyes.data.status(from:to);
     

     m_onset  = min( find(st == 3) ) + from - 1; %first onset
     m_offset = min( find(st == 4) ) + from - 1; %first offset
     
     
    if ~isempty(m_onset) & ~isempty(m_offset)
     
        %calucating times 
        times  = d.eyes.data.tStamps([ m_onset m_offset ]); % (1) onset (2) offset
        tr(m,14) = times(1) - tr(m,stimOn);
        %tr(m,15) = times(2) - times(1);
     
    end  
    
    % error type
    if ~isnan(tr(m,11))
        tr(m, 15) = d.events.stimuli(m, tr(m,11) ) ;
    end
    
    % noDistractors
    switch length( find( d.events.stimuli(m, 1:16) > 0 ) )
    case 16
        tr(m, 16) = 2;
    case 7
        tr(m, 16) = 1;
    otherwise
        fprintf('%s', '?');
        tr(m, 16) = nan;
    end
    
    
    %feedback
      if mod(m, 10) == 1
            fprintf('%s', '.');
      end;
     
end
disp(' ');
d.analysed.trials = tr;


%
%saving
%
eval([filename ' = d;']);
disp(['- save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);
eval(['save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);


diary off;

