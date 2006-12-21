function[ ] = log(event, fp)
%
% Use pointer to write an event to a log file
%
time = clock; 
fprintf(fp, '%i:%i:%2.3f\t%s\n', time(4), time(5),time(6), event);
  
 