function[ fp, name ] = createlog(path, name)
    
      folder = datestr(now, 'yyyymmdd');
      try      
          if ~exist([path folder], 'dir')
              mkdir([path folder]);
          else
              fprintf('Subfolder for day already exists.\n');
          end
          path = [path folder '/'];
      catch
          fprintf('Could not create subfolder for day\n')
      end
      d = datestr(now);
      d = regexprep(d, ' ', '_');
      d = regexprep(d, ':', '.');
      filename = [path name '_' d];
      fp = fopen(filename, 'w');
      name = filename;  
      % print headers
      fprintf(fp, 'time\tdescription\n');