function[] = timings(trials)

for i = 1:length(trials)
    f = length(trials(i).fixations);
    d = round(trials(i).duration / 1000);
    fprintf('trial %3d\t%3f\t%2d fixations\n', i, d, f);
end