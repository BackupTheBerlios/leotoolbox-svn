function DownloadLeoToolbox
commandwindow;
svnpath='/usr/local/bin/';


checkoutcommand=[svnpath 'svn checkout svn://svn.berlios.de/leotoolbox/'];


fprintf('The following CHECKOUT command asks the Subversion client to \ndownload the Leotoolbox:\n');
fprintf('%s\n',checkoutcommand);
fprintf('Downloading. It can take many minutes. \nAlas there is no output to this window to indicate progress until the download is complete. \nPlease be patient ...\n');
if IsOSX
    [err,result]=system(checkoutcommand);
else
    [err,result]=dos(checkoutcommand);
end

