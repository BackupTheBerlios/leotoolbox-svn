function[] = keyboards

d = PsychHID('Devices');

for i = 1: size(d, 2)
    fprintf('%d.\t%s\n', i, d(i).manufacturer);
    fprintf('   \t%s\n', d(i).product);
end