function[ cmd, params ] = parse_iview_command( string )
  param_divider = '(\ )|(\t)';
  
  string = regexprep(string, '\n', '');
  spaces = regexp(string, param_divider);

  
  
  start = 1; J = 1;
  cmd = '';
  ep = 0;
  for I = 1:size(spaces, 2)
      if start == 1,
          cmd = string(start:spaces(I)-1);
      else
          ep = iview_command(cmd);
          if (ep > 0),
              parameter = str2num(char([ string(start:spaces(I)-1) ]));
              params(J) = parameter;
              J = J+1;
          end;
      end;
      start = spaces(I)+1;

  end;
  ep = iview_command(cmd);
  
  if ep > 0,
    params(J) = str2num(char([ string(start:size(string, 2)) ]));  
  else
    params = [];
  end;
      