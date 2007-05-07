function makedir(newdir)

% make a new directory but only if it doesn't already exist
% this should avoid Matlab's obsolete warning messages

% exist(newdir, 'dir')

if 7==exist(newdir,'dir')
    return
else
    mkdir(newdir)
end