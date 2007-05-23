function UpdateLeoToolbox
commandwindow;
svnpath='/usr/local/bin/';


checkoutcommand=[svnpath 'svn update'];


fprintf('The following Update command asks the Subversion client to \nupdate the Leotoolbox:\n');
fprintf('%s\n',checkoutcommand);
fprintf('Updating. It can take a while. \nPlease be patient ...\n');
if IsOSX
    [err,result]=system(checkoutcommand);
else
    [err,result]=dos(checkoutcommand);
end

