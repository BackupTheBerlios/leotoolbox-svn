function[] = cleanup( parameters )

  eyefile = parameters(7).value;
  fprintf('The eyelink data can be found in : %s', eyefile);
  
  Eyelink('ReceiveFile', 'salexp.eye', eyefile );