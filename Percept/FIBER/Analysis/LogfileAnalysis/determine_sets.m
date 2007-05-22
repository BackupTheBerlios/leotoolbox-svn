function[ output] = determine_sets(data)

if nargin == 0
    data = readIDFevents;
end

%read log file
logfile = read_logfile;

[set_timings indices] = extract_set_timings(logfile);

i = 1;
t = 1;
set = 1;

%offset = data(2).fixations(1).start
for s = 1:length(data)
    
    fixations = data(s).fixations;

    for j = 1: length(fixations)
        xtemp = fixations(j).start / 1000; %% convert to minutes
        ytemp = fixations(j).duration;
        
        fprintf('start : %3.3f\t end : %3.3f\t fixation : %3.3f\n',  set_timings(set), set_timings(set +1), xtemp);
        if (set < length(set_timings) -1)
            
            if (xtemp > set_timings(set))
                
                if (xtemp < set_timings(set + 1))
                        output(set).set{1} = logfile{indices(set),1};
                        output(set).set{2} = logfile{indices(set),2};
                        output(set).set{3} = logfile{indices(set),3};
                        output(set).set{4} = logfile{indices(set),4};
                        output(set).set{5} = logfile{indices(set),5};

                        
                    output(set).fixations(i) = fixations(j);
                    i=i+1
                else
                    set = set +1;
                    i = 1;
                end
            end
        end        
    end   
end



function[timings indices] = extract_set_timings(logdata)

t = 1;
trigger = false;

start = 0;

for i = 1:length(logdata)
   
    description = logdata{i,5};
    
    if (~isempty(strfind(description, 'got  trigger pulse')) && (~(trigger)))
        start = logdata{i, 4}
        trigger = true;
    end;
    
    if strfind(description, 'starting')
        if (start > 0)
            timings(t) = logdata{i, 4} - start;
            indices(t) = i;
            t = t +1;
        end
    end
    
end
    
