function[ ] = log(event, fp)
%
% Use pointer to write an event to a log file
%
time = clock; 
time2 = GetSecs;
fprintf(fp, '%i\t%i\t%2.3f\t%s\t%s\n', time(4), time(5),time(6), num2str(time2), event);
  
fprintf('%i:%i:%2.3f\t%s\t%s\n', time(4), time(5),time(6), num2str(time2), event);
