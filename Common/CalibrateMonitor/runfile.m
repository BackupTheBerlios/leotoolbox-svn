function runfile
%
% function run color calibration routine
%
% This is the main routine for measuring colors with the Minolta CS100-A
% color meter. The program is an OSX adaptation of the OS9 cmp program by R. van
% den Berg & J. J. van Es, with alterations by T. Vladusich
%
% after typing runfile in the Matlab prompt you will be presented with a
% pop up menu with the main following options:
%
% Measurement Type: - choose 1 if you want to do a full gun measurement
% (going from dac = 0 to dac = 255 for red, green, blue, and white guns)
%                   - choose 2 if you want to measure certain RGB triplets
% (after choosing this you will be prompted for a (text) file containing
% the RGB values; for an example see 'example.txt')
%
% If you choose to do a full gun measurement you can define the interval at
% which dacs have to be measured (DAC stepsize)
%
% There are further options to simulate the color meter (1 for simulate, 0
% for no simulation), the port number that has to be used (with our
% current setup use port = 2), and the time between aiming and starting the
% measurements (time to leave the room)
%
% First Version: 31-01-2007 
% Author: J.J. van Es / R. van den Berg


AssertOpenGL
clear all

fprintf('Colour Measurement Program 2.0 (for Minolta CS100A & OSX)\n');

% settings
par = [];
fprintf('Getting settings\n');
par = getSettings;

% break from program when cancel is pressed
if par.abort == 1
    fprintf('User requested break\n');
    return
end

% initialise color meter and test connection
fprintf('Initialising color meter\n');
[par connFail] = initCM(par);

% break from program if port -1 is set in initCM
if connFail == 1
    return
end

% do measurement series

% first prepare measurement. Convert either user input .txt file or dac
% range to the RGB_vec used for measurement
[par] = prepareMeasurement(par);

% Use the same break command if something goes wrong with the
% txt-file
if par.abort == 1
    fprintf('The specified input file does not exist... Please check.\n')
    return
end

% actual measurements
[par] = doMeasure2(par);
   
if par.abort == 1
    fprintf('User requested break  \n')
    return
end

% write results and clean up
if par.meas.simulate ~= 1

    [par] = writeResults(par);
    
    %close serial port
    SerialComm('close', par.cm.port);
    
end

fprintf('Bye...\n'); 