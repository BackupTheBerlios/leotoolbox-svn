function edfanalysis

% version for NaturalGazeExperiment

fprintf('Eyelink data parser for NaturalGazeExperiment\n');

commandwindow
clear all
edfdatadir='edfdata';
ascdatadir='ascdata';
analysisdir='analysis';

edffile='jb1';
edffile='f1_dots10000';
edffile='f1_test10000';
edffile='f3_text10000';

edffile={'vy1_ng', 'vy2_ng', 'data1_ng'};
edffile={'jb1_ng', 'eg1_ng'};

edf2ascconverter=[filesep 'Programma''s' filesep 'Eyelink' filesep 'edf2asc']

fprintf('Reading and parsing eyelink data...\n');


for k=1:length(edffile)

    myAscFile=[ascdatadir filesep edffile{k} '.asc'];

    exist(myAscFile);

    % return

    if 2~=exist(myAscFile)
        if ~exist([edfdatadir filesep edffile{k} '.edf'])
            fprintf('No eyetracking data found! (file %s.edf is missing).\n', edffile{k});
            continue
        end
        fprintf('Eyelink data not converted to ASC yet. Will do that now...\n');
        waitSecs(0.25);
        cstr=[edf2ascconverter ' ' pwd filesep edfdatadir filesep edffile{k} '.edf']
        %     cstr=[edf2ascconverter ' ' pwd filesep edfdatadir filesep '*.*']
        system(cstr);
    end

    if 2~=exist(myAscFile)
        fprintf('File ''%s'' not found.\n', myAscFile);
        continue;
    end

    fid = fopen(myAscFile);
    if fid<0
        fprintf('Could not open file ''%s''.\n', myAscFile);
        continue;
    end


    outfile=[analysisdir filesep edffile{k} '_analysis.txt'];
    outfid=fopen(outfile,'w');
    if outfid<0
        error(['error creating output file: ' outfile]);
    end
    fprintf(outfid, 'TRIALID\tIMAGE\tORIENTATION\tFNR\tTIME2DISPON\tFDUR\tTIME2DISPOFF\tXPOSFIX\tYPOSFIX\tFIXNR\tINVFIXNR\n');



    done=0;

    while ~done

        dispOnTime=-999;
        % find start of trial
        trialID=findTrialID(fid);
        if trialID<0
            break;
        end

        fprintf('Trial %d\n', trialID );
        % get image name
        imgname=findImageName(fid);
        if imgname<0
            break;
        end
        imori=findImageOrientation(fid);
        if isempty(imori)
            break;
        end
        % find saccade target onset time, which marks actual trial start
        saccTarOnTime=findSaccTargetOnset(fid);
        if saccTarOnTime<0
            break;
        end

        % parse event list for fixation events and collect relevant time events
        saccTarHitTime=-999;
        dispOnTime=-999;
        dispOffTime=-999;
        trialEndTime=-999;
        fixNr=0;
        fix=[];
        while 1
            s=fgetl(fid);
            if s==-1
                break;
            end
            if 1==strncmp(s,'MSG',3)
                if ~isempty(findstr(s,'SACCADE TARGET HIT'))
                    [msgstr, saccTarHitTime, code, code, code] = strread(s,'%s%d%s%s%s');
                    event=2;
                elseif ~isempty(findstr(s,'DISPLAY ON'))
                    [msgstr, dispOnTime, code] = strread(s,'%s%d%s');
                elseif ~isempty(findstr(s,'DISPLAY OFF'))
                    [msgstr, dispOffTime, code] = strread(s,'%s%d%s');
                elseif ~isempty(findstr(s,'TRIAL END'))
                    [msgstr, trialEndTime, code] = strread(s,'%s%d%s');
                    break;
                end
            elseif 1==strncmp(s,'SFIX',4)
                [sfixstr, eyestr, stime] = strread(s,'%s%s%d');
            elseif 1==strncmp(s,'EFIX',4)
                fixNr=fixNr+1;
                [efixstr, eyestr, stime, etime, fdur, pos(1), pos(2), pup] = strread(s,'%s%s%d%d%d%f%f%d');

                fix(fixNr).stime=stime;
                fix(fixNr).etime=etime;
                fix(fixNr).dur=fdur;
                fix(fixNr).pos=pos;

            end
        end

        firstFix=-999;
        lastFix=-999;
        for i=1:length(fix)
            fix(i).timeSinceSaccTargetOnset=fix(i).stime-saccTarOnTime;
            fix(i).timeSinceDispOnset=fix(i).stime-dispOnTime;
            fix(i).timeToDispOffset=dispOffTime-fix(i).stime;

            if firstFix<0 && fix(i).timeSinceDispOnset>0
                firstFix=i;
            end
            if lastFix<0 && fix(i).timeToDispOffset<0
                lastFix=i;
            end
        end

        if firstFix<0
            firstFix=length(fix)+1;
        end
        if lastFix<0
            lastFix=length(fix);
        end
        for i=1:length(fix)
            fix(i).fixNr=i-firstFix+1;
            fix(i).invFixNr=abs(i-lastFix);
        end

        %     print relevant information
        for i=1:length(fix)
            fprintf(outfid, '%d\t%s\t%d\t', trialID, imgname, imori);
            fprintf(outfid, '%d\t%d\t%d\t', i, fix(i).timeSinceDispOnset, fix(i).dur, fix(i).timeToDispOffset);
            fprintf(outfid, '%.1f\t%.1f\t', fix(i).pos(1), fix(i).pos(2));
            fprintf(outfid, '%d\t%d\n', fix(i).fixNr, fix(i).invFixNr );
        end

        %     fprintf('\n');
    end
    fclose(fid);
    fclose(outfid);
end

%****************functions****************

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


% function time=findDisplayOnset(fid)
% time=-999;
% while 1
%     s=fgetl(fid);
%     if s==-1
%         break;
%     end
%     if 1==strncmp(s,'MSG',3)
%         if ~isempty(findstr(s,'DISPLAY ON'))
%             [msgstr, time, code] = strread(s,'%s%d%s');
%             return
%         end
%     end
% end

% function [stime, etime, sdur, spos, epos, samp, pup, eyestr]=findSaccadeEvent(fid)
% stime=-999;
% etime=-999;
% spos=[-999 -999];
% epos=[-999 -999];
% samp=-999;
% pup=-999;
% while 1
%     s=fgetl(fid);
%     if s==-1
%         break;
%     end
%     if 1==strncmp(s,'ESACC',5)
%         [esaccstr, eyestr, stime, etime, sdur, spos(1), spos(2), epos(1), epos(2), samp, pup] = strread(s,'%s%s%d%d%d%f%f%f%f%f%f');
%         return
%     end
% end
%
% function [stime, etime, fdur, pos, pup, eyestr]=findFixationEvent(fid)
% stime=-999;
% etime=-999;
% pos=[-999 -999];
% pup=-999;
% while 1
%     s=fgetl(fid);
%     if s==-1
%         break;
%     end
%     if 1==strncmp(s,'EFIX',4)
%         [efixstr, eyestr, stime, etime, fdur, pos(1), pos(2), pup] = strread(s,'%s%s%d%d%d%f%f%d');
%         return
%     end
% end
%
% function [stime, etime, fdur, pos, pup, eyestr, dispofftime]=findNextFixationEvent(fid)
% % we first detect a SFIX event, and if so, we continue looking for a
% % EFIX event
% % we also check whether the display wasn't switched off yet
% stime=-999;
% etime=-999;
% dispofftime=-999;
% pos=[-999 -999];
% pup=-999;
% fixevent=0;
% while 1
%     s=fgetl(fid);
%     if s==-1
%         break;
%     end
%     if 1==strncmp(s,'MSG',3)
%         if ~isempty(findstr(s,'DISPLAY OFF'))
%             [msgstr, dispofftime, code] = strread(s,'%s%d%s');
%         end
%     elseif 1==strncmp(s,'SFIX',4)
%         [sfixstr, eyestr, stime] = strread(s,'%s%s%d');
%         fixevent=1;
%     elseif fixevent==1 & 1==strncmp(s,'EFIX',4)
%         [efixstr, eyestr, stime, etime, fdur, pos(1), pos(2), pup] = strread(s,'%s%s%d%d%d%f%f%d');
%         fixevent=2;
%     end
%     if fixevent==2
%         return
%     end
% end
%
%
% function nr=findTargetNr(fid)
% nr=-999;
% while 1
%     s=fgetl(fid);
%     if s==-1
%         break;
%     end
%     if 1==strncmp(s,'MSG',3)
%         if ~isempty(findstr(s,'TARGET'))
%             [msgstr, time, code, nr] = strread(s,'%s%d%s%d');
%             return
%         end
%     end
% end


function name=findImageName(fid)
name=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'IMAGE'))

            si=findstr(s,'IMAGE')+length('IMAGE')+1;
            imgnamel=length(s(si:end));
            formatstr=['%s%d%s%' num2str(imgnamel) 'c'];
            [msgstr, time, code, name] = strread(s, formatstr);
            % [msgstr, time, code, name] = strread(s, '%s%d%s%s', 'whitespace', ''  )
            return
        end
    end
end


function orientation=findImageOrientation(fid)
orientation=[];
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'IMAGE_ORIENTATION'))
            [msgstr, time, code, orientation] = strread(s, '%s%d%s%d');
            return
        end
    end
end


function time=findSaccTargetOnset(fid)
time=-999;
while 1
    s=fgetl(fid);
    if s==-1
        break;
    end
    if 1==strncmp(s,'MSG',3)
        if ~isempty(findstr(s,'SACCADE TARGET ON AT'))
            [msgstr, time, code, code, code, code, xpos, ypos] = strread(s,'%s%d%s%s%s%s%d%d');

            %             [msgstr, time, code] = strread(s,'%s%d%s');
            return
        end
    end
end
