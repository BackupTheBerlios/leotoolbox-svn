function AddToLeo( mfile )

commandwindow;
svnpath='/usr/local/bin/';
action = 'add';

if nargin == 0;
    mfile = '*';
elseif nargin == 1;
end

addcommand = [svnpath 'svn ' action ' ' mfile]

if IsOSX
    
    [err,result]=system(addcommand);
else
    [err,result]=dos(addcommand);
end
        
if (err)
    sprintf(result);
else
    fprintf('File(s) : %s, have been added to the leotoolbox.\n', mfile);
end