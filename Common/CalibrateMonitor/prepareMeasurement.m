function [par]=prepareMeasurement(par)

switch par.meas.measType
    
    case 1 % full range dac measurement
        
        startDac = 0;
        stopDac = 255;
        
        baseVec = startDac;
        dac = startDac;
        
        while (dac + par.meas.dacStep) < stopDac
            
            dac = dac + par.meas.dacStep;
            baseVec = [baseVec, dac];
        end
        
        baseVec = [baseVec, stopDac]';
        par.meas.dacs = baseVec;
        
        compVec = zeros(1, length(baseVec))';
        
        par.meas.RGB_vec = [baseVec, compVec, compVec;...
                            compVec, baseVec, compVec;...
                            compVec, compVec, baseVec;...
                            baseVec, baseVec, baseVec];
        
        
    case 2 % user input textfile
        
        % open a textfile containing the RGB values
        [inputFile inputPath] = uigetfile('*.*', 'Choose input file'); 
        
        if inputFile == 0 
            fprintf('Program aborted by user. \n\n');
            par.abort = 1;
            return
            
        else
            
            par.meas.inputFile = [inputPath inputFile];
            fid = fopen(par.meas.inputFile);

            linenumber = 0;
            line = 0;

            while line ~= -1
                
                linenumber = linenumber + 1;
                line = fgets(fid);
                    
                if line ~= -1

                    [R(1, linenumber) G(1, linenumber) B(1, linenumber)] = strread(line);
                end
    
            end
            
            par.meas.RGB_vec = [R', G', B'];
            fclose(fid);
        end
        
    otherwise
        
        par.abort = 1;
        fprintf('Something went wrong... Measure type was not 1 or 2/n');
        return
end
