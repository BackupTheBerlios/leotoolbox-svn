function CommitLeo( mfile, comments )


UpdateLeoToolbox; %% full checkout befor commit
GoToLeoPath
commandwindow;
svnpath='/usr/local/bin/';
action = 'ci';

if nargin == 0;
    mfile = '*';
    comment = input('Comments : ');
elseif nargin == 1;
    comment = input('Comments : ');
end

checkincommand = [svnpath 'svn ' action ' ' mfile ' --message "' comment '"']

if IsOSX
    [err,result]=system(checkincommand);
else
    [err,result]=dos(checkincommand);
end
        
    sprintf(result);
if (err)
    sprintf(result);
else
    fprintf('File(s) : %s, local changes have been added to leotoolbox.\n', mfile);
end



    