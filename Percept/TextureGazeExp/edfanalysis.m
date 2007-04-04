function edfanalysis

commandwindow
clear all
edfdatadir='edfdata';
ascdatadir='ascdata';
edf2ascconverter=[filesep 'Programma''s' filesep 'Eyelink' filesep 'edf2asc']

edffile={'jb3cu','jb4cu','jb5cu'};


fprintf('Reading and parsing eyelink data...\n');


for k=1:length(edffile)

    myAscFile=[ascdatadir filesep edffile{k} '.asc']

    exist(myAscFile);

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


    fprintf('TRIALID\tTPOS\tCHOICEPOS\tLATENCY\n');
    done=0;

    while ~done
        tpos=-999;
        trialID=findTrialID(fid);
        if trialID<0
            break;
        end
        stime=findDisplayOnset(fid);
        if stime<0
            break;
        end

        % find first saccade with starttime that is later than the display
        % onset
        sstime=stime-1;
        while sstime<stime
            [sstime, setime, sdur, sspos, sepos, samp, pup, eyestr]=findSaccadeEvent(fid);
        end
        if sstime<0
            break;
        end
        slat=sstime-stime; % saccadic latency

        % find first fixation event
        [stime, etime, fdur, pos, pup, eyestr]=findFixationEvent(fid);
        if stime<0
            break;
        end

        target=findTargetNr(fid);
        if target<0
            break;
        end

        %   fprintf('TRIALID\tTPOS\tCHOICEPOS\tLATENCY\n');
        fprintf('%d\t%d\t%d\t%d\n', trialID, tpos, target, slat);

    end

    fclose(fid);

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
        if ~isempty(findstr(s,'TARGET'))
            [msgstr, time, code, nr] = strread(s,'%s%d%s%d');
            return
        end
    end
end

