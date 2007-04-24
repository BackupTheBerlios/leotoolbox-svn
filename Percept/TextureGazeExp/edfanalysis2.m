function edfanalysis

commandwindow
clear all
edfdatadir='edfdata';
ascdatadir='ascdata';
datadir='fixeddatafiles';
outdir='fixeddatafiles';
edf2ascconverter=[filesep 'Programma''s' filesep 'Eyelink' filesep 'edf2asc']

saccThreshold=3.5;

edffile={'jb3cu','jb4cu','jb5cu'};
edffile={'jb5cu'};

% edffile={'jb3cu'};
datafile={'jb_3_cu_TextureGazeExp8', 'jb_4_cu_TextureGazeExp8', 'jb_5_cu_TextureGazeExp9'};
datafile={'jb3cu', 'jb4cu', 'jb5cu'};
datafile={'jb5cu'};

fprintf('Reading and parsing eyelink data...\n');


for k=1:length(edffile)

    totaalgelijk=0;
    
    myAscFile=[ascdatadir filesep edffile{k} '.asc']

    myDataFile=[datadir filesep datafile{k} '_data.txt']

    myOutFile=[outdir filesep datafile{k} '_lat.txt']


    % return

    if 2~=exist(myAscFile)
        if ~exist([edfdatadir filesep edffile{k} '.edf'])
            fprintf('No eyetracking data found! (file %s.edf is missing).\n', edffile{k});
            return
        end
        fprintf('Eyelink data not converted to ASC yet. Will do that now...\n');
        waitSecs(0.25);
        cstr=[edf2ascconverter ' ' pwd filesep edfdatadir filesep edffile{k} '.edf']
        system(cstr);
    end

    if 2~=exist(myAscFile)
        fprintf('File ''%s'' not found.\n', myAscFile);
        return;
    end

    fid = fopen(myAscFile);
    if fid<0
        fprintf('Could not open file ''%s''.\n', myAscFile);
        return;
    end

    fid2 = fopen(myOutFile,'w');
    if fid2<0
        fprintf('Could not open file ''%s''.\n', myOutFile);
        return;
    end
    
    [data colnames]=autotextread(myDataFile);
    
    data
    
    fprintf(fid2, 'TRIALID\tSACCNR\tTPOS\tCHOICE\tORIENT\tGAPTIME\tLATENCY\n');
    done=0;

    while ~done
        tpos=-999;
        trialID=findTrialID(fid);
        if trialID<0
            break;
        end
        
        if 1 && trialID>320
            fprintf('%d\n', trialID);
        end
            
        
        
        
        
        % parse event list for fixation events and collect relevant time events
        gapOnTime=-999;
        dispOnTime=-999;
        dispOffTime=-999;
        trialEndTime=-999;
        stime=-999;
        stime2=-999;
        saccNr=0;
        sacc=[];
        slat=-999;
        while 1
            s=fgetl(fid);
            if s==-1
                break;
            end
            
            if 1==strncmp(s,'MSG',3)
                if ~isempty(findstr(s,'GAP ON'))
                    [msgstr, gapOnTime, code] = strread(s,'%s%d%s');
                elseif ~isempty(findstr(s,'DISPLAY ON'))
                    [msgstr, dispOnTime, code] = strread(s,'%s%d%s');
                elseif ~isempty(findstr(s,'DISPLAY OFF'))
                    [msgstr, dispOffTime, code] = strread(s,'%s%d%s');
                elseif ~isempty(findstr(s,'TRIAL END'))
                    [msgstr, trialEndTime, code] = strread(s,'%s%d%s');
                    break;
                elseif ~isempty(findstr(s,'CHOICE'))
                    [msgstr, choiceTime, code choice ] = strread(s,'%s%d%s%d');                 
                elseif ~isempty(findstr(s,'TARGET_ORIENTATION'))
                    [msgstr, choiceTime, code t_orient ] = strread(s,'%s%d%s%d');                    
                end
            elseif 1==strncmp(s,'SSACC',4)
                [ssaccstr, eyestr, stime] = strread(s,'%s%s%d');
            elseif 1==strncmp(s,'ESACC',4)
                % first read it as a string, so check for '.' values
                [esaccstr, eyestr, tstime2, tetime, tsdur, tspos(1), tspos(2), tepos(1), tepos(2), tsamp, tpup] = strread(s,'%s%s%s%s%s%s%s%s%s%s%s');
                
                if ~(isdot(tspos(1)) || isdot(tspos(2)) || isdot(tepos(1)) || isdot(tepos(2)) || isdot(tsamp) || isdot(tpup))
                    [esaccstr, eyestr, stime2, etime, sdur, spos(1), spos(2), epos(1), epos(2), samp, pup] = strread(s,'%s%s%d%d%d%f%f%f%f%f%f');
                else
                    continue;
                end
                
%                 d=sqrt((spos(1)-epos(1))^2 + (spos(2)-epos(2))^2);
                
                %             elseif 1==strncmp(s,'SFIX',4)
%                 [sfixstr, eyestr, stime] = strread(s,'%s%s%d');
%             elseif 1==strncmp(s,'EFIX',4)
%                 [efixstr, eyestr, stime, etime, fdur, pos(1), pos(2), pup] = strread(s,'%s%s%d%d%d%f%f%d');
            end
            
            if dispOnTime>0 && stime2>0
                if stime2-dispOnTime>0
                    if samp>saccThreshold % some threshold
                        saccNr=saccNr+1;
                    end
                end
            end
            if saccNr>0                   
                break;
            end

        end


        %     print relevant information
%         for i=1:length(fix)
%             fprintf(outfid, '%d\t%s\t%d\t', trialID, imgname, imori);
%             fprintf(outfid, '%d\t%d\t%d\t', i, fix(i).timeSinceDispOnset, fix(i).dur, fix(i).timeToDispOffset);
%             fprintf(outfid, '%.1f\t%.1f\t', fix(i).pos(1), fix(i).pos(2));
%             fprintf(outfid, '%d\t%d\n', fix(i).fixNr, fix(i).invFixNr );
%         end
% 

        
        
        gapTime=dispOnTime-gapOnTime;
        slat=stime2-dispOnTime;
        
        if choice<0
%             break;
        end
        tpos=data.TPOS(trialID);
                ch2=data.CHOICE(trialID);
        isgelijk=ch2==choice;
        totaalgelijk=totaalgelijk+isgelijk;
        %   fprintf('TRIALID\tSACCNR\tTPOS\tCHOICE\tLATENCY\n');
        fprintf(fid2,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n', trialID, saccNr, tpos, choice, t_orient, gapTime, slat);

        if 0 && trialID>50
            break;
        end
        
    end

    fclose(fid);
    fclose(fid2);
    totaalgelijk
end

% *********************************************

function id=findTrialID(fid)
id=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'TRIALID'))
            [msgstr, time, code, id] = strread(s,'%s%d%s%d');
            return
        end
    end
end


function time=findDisplayOnset(fid)
time=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'DISPLAY ON'))
            [msgstr, time, code] = strread(s,'%s%d%s');
            return
        end
    end
end

function [stime, etime, sdur, spos, epos, samp, pup, eyestr]=findSaccadeEvent(fid)
stime=-999;
etime=-999;
spos=[-999 -999];
epos=[-999 -999];
samp=-999;
pup=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'ESACC',5)
        [esaccstr, eyestr, stime, etime, sdur, spos(1), spos(2), epos(1), epos(2), samp, pup] = strread(s,'%s%s%d%d%d%f%f%f%f%f%f');
        return
    end
end

function [stime, etime, fdur, pos, pup, eyestr]=findFixationEvent(fid)
stime=-999;
etime=-999;
pos=[-999 -999];
pup=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'EFIX',4)
        [efixstr, eyestr, stime, etime, fdur, pos(1), pos(2), pup] = strread(s,'%s%s%d%d%d%f%f%d');
        return
    end
end


function nr=findTargetNr(fid)
nr=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'CHOICE'))
            [msgstr, time, code, nr] = strread(s,'%s%d%s%d');
            return
        end
    end
end

function result=isdot(s)
result=0;
if 1==strcmp(s,'.')
    result=1;
end
