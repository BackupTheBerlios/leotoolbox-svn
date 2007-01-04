function[ cmd, params ] = parse_iview_command( string )
  spaces = strfind(string, ' ');
  oddchar = 
  start = 1; J = 1;
  cmd = '';
  for I = 1:size(spaces, 2)
      if start == 1,
          cmd = string(start:spaces(I)-1);
      else
          params(J,:) = [ string(start:spaces(I)-1) ];
          J = J+1;
      end;
      start = spaces(I)+1;

  end;
  params(J,:) = [ string(start:size(string, 2)) ];