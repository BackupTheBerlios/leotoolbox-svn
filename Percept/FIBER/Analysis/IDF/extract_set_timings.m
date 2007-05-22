function[timings filename] = extract_set_timings(filename)


if nargin == 0
    [logdata filename] = read_logfile;
else
    logdata= read_logfile(filename);
end

t = 1;
trigger = false;

start = 0;

for i = 1:length(logdata)
   
    description = logdata{i,5};
    
    if (~isempty(strfind(description, 'got  trigger pulse')) && (~(trigger)))
        start = logdata{i, 4};
        trigger = true;
    end;
    
    if strfind(description, 'stimulus')
        if (start > 0)
            timings(t) = logdata{i, 4} - start;
            indices(t) = i;
            t = t +1;
        end
    end    
end

if ~trigger
    error(sprintf('Corrupt logfile!\nNo trigger puls comment found\n'));
end