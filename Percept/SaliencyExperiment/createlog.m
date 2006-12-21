function[ fp, name ] = createlog(name)

      d = datestr(now);
      d = regexprep(d, ' ', '_');
      d = regexprep(d, ':', '.');
      filename = [name '_' d];
      fp = fopen(filename, 'w');
      name = filename;  
      % print headers
      fprintf(fp, 'time\tdescription\n');