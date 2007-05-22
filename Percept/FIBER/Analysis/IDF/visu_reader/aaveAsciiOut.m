function aaveAsciiOut(ped, filename)


%witch columns should be also in result file 
OutColumns =[1:3 8:12 15];

if size(ped.analysed.trials,2) == 16  % with sound
	OutColumns = [OutColumns 16];
end


disp('   calculating  acceleration');
acc = [nan; diff(ped.analysed.velocity)];

%%%
% ANALYSE TRIALS
%%%

fprintf('%s','- analysing trialswise');

OutColumns = [OutColumns 20:23];
tr = ped.analysed.trials;
tr(:,20:23) = nan;
noTrials = size(tr,1);

stimOn  = 6;
stimOff = 7;
firstFixObject = 12;
rtCol = 20;
erCol = 21;
noDistCol = 22;
accCol = 23;
sound = 16;

varNames =ped.analysed.varNames;
varNames(rtCol) ={'RT'};
varNames(erCol) ={'errType'};
varNames(noDistCol) ={'noDist'};
varNames(accCol) ={'accel'}; %acceleration at detected movement onset


for m =1:noTrials

     %from & to
     from = findTimeStamps(ped.eyes.data.tStamps, tr(m, stimOn) ,1);
     to   = findTimeStamps(ped.eyes.data.tStamps, tr(m, stimOff) ,1);
     
     if isnan(from) | isnan(to)
         st = NaN;
     else
         st = ped.eyes.data.status(from:to);
     end
     m_onset  = min( find(st == 3) ) + from - 1; %first onset
     m_offset = min( find(st == 4) ) + from - 1; %first offset
    if ~isempty(m_onset) & ~isempty(m_offset)
        %calucating times 
        times  = ped.eyes.data.tStamps([ m_onset m_offset ]); % (1) onset (2) offset
        tr(m,rtCol) = times(1) - tr(m,stimOn);
        %tr(m,??) = times(2) - times(1);
        tr(m,accCol) = mean(ped.analysed.accel(m_onset+1:m_onset+1)); % Schaetzung der Bescheunigung Schelle
                                            % ueber Beschleunung bei onset und Beschleunigung ein Sample vorher
    end  
    
    % error type
    if ~isnan(tr(m,firstFixObject))
        tr(m, erCol) = ped.events.stimuli(m, tr(m,firstFixObject) ) ;
    end
    
    % noDistractors
    tr(m, noDistCol) = length( find( ped.events.stimuli(m, 1:ped.events.noPositions) > 0 ) )-1;
    
    %feedback
     if mod(m, 10) == 1
            fprintf('%s', '.');
     end;
end



%%%
% ASCII OUT 
%%%
missing = ['-99'];

tr = tr(:,OutColumns);
varNames = varNames(OutColumns)  ;

fid = fopen([filename] ,'w');
  %Varname
  for co=1:length(OutColumns);
      fprintf(fid,[char(varNames(co)) ' \t']);
  end
  fprintf(fid,'\n');
  
  %data
  for z = 1:size(tr,1)
    for co = 1:length(OutColumns)
      cl = tr(z,co);
      if OutColumns(co)==20 % RT column  
          outFormat = '%10.4f\t';
      else
          outFormat = '%10.0f\t';
      end;
      
      if ~isnan(cl)
        fprintf(fid,outFormat,cl);
      else
        fprintf(fid,[missing ' \t']);
      end
    end
    fprintf(fid,'\n');
  end;
  fclose(fid);

 disp(' ');
 beep;
  %type( filename );
 
