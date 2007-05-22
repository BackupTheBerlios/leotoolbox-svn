function[ data ] = readIDFexport( filename )
if nargin ==0
    cd '/Users/marsman/Documents/Programming/Matlab/leotoolbox/Percept/IDF/sample';
    [f, path] = uigetfile({'*.txt; *.dat'},'Choose an ascii-exported IVIEW file');
    filename = [path f];
end

file = fopen(filename, 'r');



%% Process the filem

index = 1; s_index = 1; h_index = 1;
while (feof(file) == false) 
    %readline of the eyedata
    lines{index} = fgets(file);
    
    start_of_samples_test = lines{index}(1:4);
    if (strcmp(start_of_samples_test, 'Time'))
        lines{index} = fgets(file);
        break;
    end;
    index = index +1;
end;
data = [];
%% process all samples

data = struct('samples', 0, 'messages', 0);
d_index = 1;
assignin('base', 'file', file);

%% open 2 temp files, 1 for smp 1 for msg
smp_tmp = tempname;
msg_tmp = tempname;

smpsink = fopen(smp_tmp, 'w');
msgsink = fopen(msg_tmp, 'w')

while (feof(file) == false) 

    line = fgets(file);
    param_divider = '(\ )|(\t)';  

    line = regexprep(line, param_divider, ' ');
    [t, rest] = strtok(line); 

    type = strtok(rest);
    if (strcmp(type, 'MSG'))
       fprintf(msgsink, '%s', line);
    end

    if (strcmp(type, 'SMP'))
       fprintf(smpsink, '%s', line);
    end;
end

fclose(smpsink);
fclose(msgsink);

smpsource = fopen(smp_tmp, 'r');
msgsource = fopen(msg_tmp, 'r');

data.samples = textscan(smpsource, '%n%s%n%n%n%n%n%n%n%n%n%n%n%n');
data.messages = textscan(msgsource, '%n%c%s');

function[ file ]  = goto_beginning_of_line( file )
    while 1
        fseek(file, -2, 'cof');
        ftell(file);
        if (fread(file, 1) == 10)
            break;
        end;
    end;
    