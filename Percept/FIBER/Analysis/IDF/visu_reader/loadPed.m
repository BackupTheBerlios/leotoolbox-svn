function d=loadPed( filename, loadSplittedData )
% function d=loadPed( filename, loadSplittedData )
% loads a peds file
%        loadSplittedData = 1: adds separate raw data  (...\rawMat\raw_<filename}>)
%        loadSplittedData = 2: adds separate filtered data (...\rawMat\raw_<filename}>)
%        loadSplittedData = 3: adds separate raw & filtered data 

% Oliver Lindemann

if nargin < 2
 loadSplittedData = 0;
end

[path, name, ext, v] = fileparts( lower(filename) );
if isempty(path)
    path = cd;
end    
path = [path '\'];
ext = '.mat';
tmp = fopen([path name ext]);
if tmp<0
    disp(['- File doesn''t exist: ' path name ext ]);
    d = createPeds;
    return
else
    fclose(tmp);
end

disp(['- getting data: ' path name ext] );
tmp = load([path name ext]);
eval(['d = tmp.' name ';']);

if loadSplittedData==1 | loadSplittedData==3
    tmp = loadPed([path 'rawMat\raw_' name ext], 0);
    if ~isempty(tmp.birds.data.pos)
           d.birds.data.pos = tmp.birds.data.pos;
           d.birds.data.rot = tmp.birds.data.rot;
    end
end

if loadSplittedData==2 | loadSplittedData==3
    tmp = loadPed([path 'filMat\fil_' name ext], 0);
    if ~isempty(tmp.birds.data.posFil)
        d.birds.data.posFil = tmp.birds.data.posFil;
        d.birds.data.rotFil = tmp.birds.data.rotFil;
    end
end

%decompress timestamps
if isfield(d.birds.data, 'tStamps')
    if length(d.birds.data.tStamps) == 2 
        d.birds.data.tStamps = linspace( d.birds.data.tStamps(1), ...
                                d.birds.data.tStamps(2),...
                                d.birds.info.nrSamples)';
    end
end

