function[] = cleanup( parameters )

  eyefile = parameters(7).value;
  Eyelink('ReceiveFile', eyefile);