function[ fp, name ] = createlog(path, name)

      d = datestr(now);
      d = regexprep(d, ' ', '_');
      d = regexprep(d, ':', '.');
      filename = [path name '_' d];
      fp = fopen(filename, 'w');
      name = filename;  
      % print headers
      fprintf(fp, 'time\tdescription\n');