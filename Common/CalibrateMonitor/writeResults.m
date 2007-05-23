function [par] = writeResults(par)

fprintf('Writing results\n');

% handle file
path = FunctionFolder(mfilename);
filename = [path '/' par.files.outputPath '/' par.files.savefile]
filename
FID = fopen(filename, 'w')

% make a general result vector
if par.meas.measType == 1 % full gun measurement

    [nM crap] = size(par.meas.RGB_vec) % number of measures per gun

    nMPG = nM/par.meas.nrGuns

    % just rename some stuff to get shorter names
    nG = par.meas.nrGuns
    mV = par.meas.measurement_vec

    reorderedVec = [];
%     reshape the vector for result writing
        for i = 1:nG
    
            reorderedVec = [reorderedVec, mV(((i - 1)*nMPG) + 1:i*nMPG, :)]
    
        end


    % general info
%     fprintf(FID,'Measurement Results for full range\n');
    fprintf(FID,'%s\t%s\t\t\t\t\t\t%s\t\t\t\t\t%s\t\t\t\t\t%s\n','DACs','RED-gun','GREEN-gun','BLUE-gun','WHITE');
    fprintf(FID,'\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\t%s\t\t%s\t\t%s\t\t\n','Y','x','y','Y','x','y','Y','x','y','Y','x','y');

    resToWrite = [par.meas.dacs, reorderedVec];

    [linesToWrite crap] = size(resToWrite)

    for t = 1:linesToWrite
        
        fprintf(FID,'%3i\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\t%6.4f\t%6.4f\t%6.4f\t\n',...
             resToWrite(t,1),resToWrite(t,2),resToWrite(t,3),resToWrite(t,4),resToWrite(t,5),resToWrite(t,6),... 
             resToWrite(t,7),resToWrite(t,8),resToWrite(t,9),resToWrite(t,10),resToWrite(t,11),resToWrite(t,12),...
             resToWrite(t,13));
    end

else % user input RGB triplets

    % general info
    fprintf(FID,'Measurement Results for single colours\n');
    fprintf(FID,'%11s  %17s\n','DAC-values','CIE-values');
    fprintf(FID,'%3s %3s %3s  %5s %6s %6s\n','R','G','B','Y','x','y');

    resToWrite = [par.meas.RGB_vec, par.meas.measurement_vec];

    [linesToWrite crap] = size(resToWrite);

    for t=1:linesToWrite

        fprintf(FID,'%3i %3i %3i %6.4f %6.4f %6.4f \n',...
            resToWrite(t,1),resToWrite(t,2),resToWrite(t,3),resToWrite(t,4),resToWrite(t,5),resToWrite(t,6));
        fprintf(FID, '\n');
    end

end

fclose(FID);