function [par] = getSettings

% DEFAULT SETTINGS
% device settings
par.cm.baudrate = 4800; % minolta dependent
par.cm.startbit = 7; % minolta dependent
par.cm.stopbit = 2; % minolta dependent
par.cm.parity = 'e'; % minolta dependent
par.cm.port = 2; % setup dependent (this works with a keyspan in the usb port)
par.cm.gwait = 3.5; % just a general wait time that is used occasionally (for instance after opening the port)
par.cm.connCheckTime=10; % time in seconds to wait for connection CM

% measurement settings
par.meas.timeToLeave = 8; % time to leave the room
par.meas.measType = 1; % 1 = full gun measurement (RGBW), 2 = input textfile with RGB values
par.meas.dacStep = 16; % the dac stepsize in which to measure
par.meas.inputFile = 'example.txt'; % default filename for an inputfile (this file exists)
par.meas.simulate = 0; % 1 if you want to simulate the minolta, 0 if you don't
par.meas.nrGuns = 4;

% screen parameters
par.screen.fontSize = 20;
par.screen.textColor = [255 80 0];
par.screen.bgColor = [0 0 0];
par.screen.screenNumber = max(Screen('Screens'));
par.screen.screenSize = [1024 768];
par.screen.screenFreq = 60;
par.screen.pixelDepth = 32;
par.screen.sizeOfRect = 20; % 20% (recommended by Marcel Lucassen)
par.screen.screenSettleTime = 0.25; % give a little time for diplay to settle before measuring

% other
par.files.savefile = 'dummy.txt';
par.files.outputPath = 'results';
par.keys.breakKey = 'escape'; % build in a break key to abort during measurement...
par.keys.quit = KbName(par.keys.breakKey);
par.abort = 0;

% make last prefs option...
if exist('lastPrefs.mat','file')

    load('lastPrefs.mat');
    par.abort = 0;

end

% User input; prompt for any changes

prompt = {'Savefile name', ...
    'Measurement type (1 = full gun measurement, 2 = user specific input (text-file))', ...
    'State DAC stepsize (Min = 1 Max = 255)', ...
    'Simulate minolta? (1 = yes, 0 = no)', ...
    'Portnumber', ...
    'Time to leave the room (set to > 1 sec)'};

default = {par.files.savefile, ...
    num2str(par.meas.measType), ...
    num2str(par.meas.dacStep), ...
    num2str(par.meas.simulate), ...
    num2str(par.cm.port), ...
    num2str(par.meas.timeToLeave)};

ans = inputdlg(prompt,'CMP -- General Settings', 1, default);

if ~isempty(ans)

    par.files.savefile = ans{1};
    par.meas.measType = str2num(ans{2});
    par.meas.dacStep = str2num(ans{3});
    par.meas.simulate = str2num(ans{4});
    par.cm.port = str2num(ans{5});
    par.meas.timeToLeave = str2num(ans{6});

else

    par.abort = 1;

end

if par.meas.simulate == 1

    par.cm.port = 0;

end

% some stuff to close off
par.cm.portString = [num2str(par.cm.baudrate), ',', par.cm.parity, ',', num2str(par.cm.startbit), ',', ...
    num2str(par.cm.stopbit)];

% check whether res directory exists
if ~exist(par.files.outputPath, 'dir')

    mkdir(par.files.outputPath);

end

save lastPrefs.mat par
