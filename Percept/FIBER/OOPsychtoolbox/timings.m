function[etimes] = timings( parameterlist )
 fliptimes    = parameterlist(4).value;
 
 for i = 1: size(fliptimes, 1) -1;
      etimes(i, 1) = etime(fliptimes(i+1,:), fliptimes(i,:));
  end;