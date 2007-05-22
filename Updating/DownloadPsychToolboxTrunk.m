function DownloadPsychToolboxTrunk

% just a shortcut for downloading PsychToolbox trunk (anonymously).

commandwindow;
flavor='trunk';


DownloadPsychtoolbox(flavor);

return


% svnpath='/usr/local/bin/';
% 
% 
% checkoutcommand=[svnpath 'svn checkout svn://svn.berlios.de/osxptb/' flavor '/Psychtoolbox/ '];
% 
% 
% fprintf('The following CHECKOUT command asks the Subversion client to \ndownload the Psychtoolbox:\n');
% fprintf('%s\n',checkoutcommand);
% fprintf('Downloading. It''s nearly 100 MB, which can take many minutes. \nAlas there is no output to this window to indicate progress until the download is complete. \nPlease be patient ...\n');
% if IsOSX
%     [err,result]=system(checkoutcommand);
% else
%     [err,result]=dos(checkoutcommand);
% end
% 
