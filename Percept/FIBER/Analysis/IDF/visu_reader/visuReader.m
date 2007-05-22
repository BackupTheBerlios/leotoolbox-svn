
function varargout = visuReader(varargin) %v2.7
% VISUREADER M-file for visuReader.fig
%      VISUREADER, by itself, creates a new VISUREADER or raises the existing
%      singleton*.
%
%      H = VISUREADER returns the handle to a new VISUREADER or the handle to
%      the existing singleton*.
%
%      VISUREADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUREADER.M with the given input arguments.
%
%      VISUREADER('Property','Value',...) creates a new VISUREADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visuReader_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visuReader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visuReader

% Last Modified by GUIDE v2.5 06-Oct-2004 17:59:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visuReader_OpeningFcn, ...
                   'gui_OutputFcn',  @visuReader_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before visuReader is made visible.
function visuReader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visuReader (see VARARGIN)

% Choose default command line output for visuReader
handles.output = hObject;




% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visuReader_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function flName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function flName_Callback(hObject, eventdata, hdl)
set(hdl.flName, 'String', lower(get(hdl.flName, 'String')));
hdl.subNum = 99;
hdl.cond = 99;
hdl.contrasts = 4;
hdl.positions = [7 0];
hdl.stimRadius = 10;
hdl.caliX = 18.2;
hdl.caliY = 14.8;
edConditions_Callback(hObject, eventdata, hdl);
edContrasts_Callback(hObject, eventdata, hdl);
edHoriz_Callback(hObject, eventdata, hdl);
edVert_Callback(hObject, eventdata, hdl);
edSubNum_Callback(hObject, eventdata, hdl);
edPositions_Callback(hObject, eventdata, hdl);
edPositions2_Callback(hObject, eventdata, hdl);
edSubNum_Callback(hObject, eventdata, hdl);
edRadius_Callback(hObject, eventdata, hdl);

% --- Executes during object creation, after setting all properties.
function edSubNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSubNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edSubNum_Callback(hObject, eventdata, hdl)
tmp  = str2num( char( get(hdl.edSubNum, 'String') ));
if ~isempty( tmp  ) 
    hdl.subNum =tmp;
end   
set(hdl.edSubNum, 'String', num2str(hdl.subNum));
guiData(hdl.mainFig, hdl);


% --- Executes on button press in btGo.
function btGo_Callback(hObject, eventdata, hdl)
name = get(hdl.flName, 'String');
headIntegration = get(hdl.cbHead, 'Value');

visuReadData(name, hdl.subNum, hdl.cond, hdl.contrasts, hdl.positions,...
                    hdl.stimRadius,[hdl.caliX hdl.caliY],  headIntegration);

beep;


% --- Executes during object creation, after setting all properties.
function edConditions_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edConditions_Callback(hObject, eventdata, hdl)
tmp  = str2num( char( get(hdl.edConditions, 'String') ));
if ~isempty( tmp  ) 
    hdl.cond =tmp;
end   
set(hdl.edConditions, 'String', num2str(hdl.cond) );
guiData(hdl.mainFig, hdl);


function edContrasts_CreateFcn(hObject, eventdata, hdl)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edContrasts_Callback(hObject, eventdata, hdl)
tmp = str2num( char( get(hdl.edContrasts, 'String') ));
if ~isempty( tmp ) 
   hdl.contrasts = tmp;
end   
set(hdl.edContrasts, 'String', num2str(hdl.contrasts) );
guiData(hdl.mainFig, hdl);


% --- Executes during object creation, after setting all properties.
function edPositions_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edPositions_Callback(hObject, eventdata, hdl) 
tmp = str2num( char( get(hdl.edPositions, 'String') ));
if ~isempty( tmp ) 
   hdl.positions(1) =tmp;
end   
set(hdl.edPositions, 'String', num2str(hdl.positions(1)) );
guiData(hdl.mainFig, hdl);

function edPositions2_Callback(hObject, eventdata, hdl)
tmp = str2num( char( get(hdl.edPositions2, 'String') ));
if ~isempty( tmp ) 
   hdl.positions(2) =tmp;
end   
set(hdl.edPositions2, 'String', num2str(hdl.positions(2)) );
guiData(hdl.mainFig, hdl);


% --- Executes during object creation, after setting all properties.
function edHoriz_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edHoriz_Callback(hObject, eventdata, hdl)
tmp = str2num( char( get(hdl.edHoriz, 'String') ));
if ~isempty( tmp ) 
   hdl.caliX = tmp;
end   
   set(hdl.edHoriz, 'String', num2str(hdl.caliX ) );
guiData(hdl.mainFig, hdl);



function edVert_CreateFcn(hObject, eventdata, hdl)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edVert_Callback(hObject, eventdata, hdl)
tmp  = str2num( char( get(hdl.edVert, 'String') ));
if ~isempty( tmp ) 
   hdl.caliY = tmp;
end   
   set(hdl.edVert, 'String', num2str(hdl.caliY) );
guiData(hdl.mainFig, hdl);


% --- Executes on button press in cbHead.
function cbHead_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edRadius_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edRadius_Callback(hObject, eventdata, hdl)
tmp = str2num( char( get(hdl.edRadius, 'String') ));
if ~isempty( tmp) 
   hdl.stimRadius = tmp ;
end   
set(hdl.edRadius, 'String', num2str(hdl.stimRadius) );
guiData(hdl.mainFig, hdl);



function visuReadData(aslFile, subNum, condition, noContrasts, noPositionsSmallLarge, ...
    radiusStimulusPositions, CaliPoiDistances, HeadIntegration)

%function visuReadData(aslFile, subNum, condition, noContrasts, noPositions, ...
%    radiusStimulusPositions, CaliPoiDistances[x,y], HeadIntegration[bool])


diary('log.txt')
%print time
c =clock;
disp(['** visuReadData  2.7 **']);
disp(['** ' num2str(c(3)) '.' num2str(c(2)) '.' num2str(c(1))...
                        ' (' num2str(c(4)) ':' num2str(c(5)) 'h) **']);


%get path and FileNames
[path,filename,ext,ver] = fileparts(aslFile);
if isempty(path)
   path = cd; 
end


d = createPeds;
d.info.files.path = path;
d.info.files.filename = filename;
d.info.files.eyeName = [filename '.asc'];
d.info.files.evtName = [filename '.evt'];
d.info.files.calName = 'the same';
d.info.subject.number = subNum;


d.events.noPositions = noPositionsSmallLarge;
d.events.noContrasts = noContrasts;

calXcm = CaliPoiDistances(1);
calYcm = CaliPoiDistances(2);
radius = radiusStimulusPositions;

%%%
%calibration file
%%%



disp(['- getting data']);

 stimulusDuration = 1.5; %sec <---------------
% ISI = 0.5;

%[d.events.data runningTime] = readEventFile(d.info.files.evtName, [StartCode StopCode]);

%%%
% the .dat file
%%%

%reading .dat file (for stimuli) NOT miniBirds file!!
[p,f,e,v] = fileparts(d.info.files.evtName);
disp(['  reading dat-file (' f '.dat' ')']);
outfilename = convertTextFile([path '\' f '.dat']);
[x] = importdata([outfilename]); 

if (size(x.data, 2) == 6)% with sound
       snd = x.data(:,6);
       disp(['  experiment with sound.']);
       x.data(:,6)=[];
else
    snd =[];
end


%stimuli: 1....? (positions) (target pos) (target type)
d.events.stimuli = [ digits( x.data(:,4) ), x.data(:,5), x.data(:,3) ];
d.events.stimuli = findThe9(d.events.stimuli); 

x.textdata = x.textdata(2:end,2);
%code trialtype 0=? 1=experimental, 9=practice
d.events.trialtype = 1*strcmp(x.textdata, 'Experimental');
tmp = strcmp(x.textdata, 'Practice');
idx = find(tmp == 1);
if ~isempty(idx)
    d.events.trialtype(idx,1) = 9;
end

%%
% make objects and ring
%%%
% calculating CalibrationPoints
%%

x = [-calXcm 0 calXcm];
y = [calYcm 0 -calYcm];

d.calibration = ...
         [x(1) y(1);   x(2) y(1);  x(3) y(1); 
          x(1) y(2);   x(2) y(2);  x(3) y(2);
          x(1) y(3);   x(2) y(3);  x(3) y(3)];



      
disp('  calculating object positions and field ring');

noPositions= d.events.noPositions(1);     
fix = [0 0];
stepAngle = 360/noPositions;
objs = deg2vec( convertAngles( [stepAngle:stepAngle:360] )' ) .* radius ;
objs(:,1) = objs(:,1) + fix(:,1);
objs(:,2) = objs(:,2) + fix(:,2);
%make last the first and add fixcross 
d.objects = [objs(noPositions,:); objs(1:noPositions-1,:); fix];
% Field Ring
shoot = [radius*0.2 radius*0.4];
d.objectFields = makeFieldRing(fix, radius, shoot, stepAngle);
d.objectFields = cat(3, d.objectFields(:,:, noPositions), d.objectFields(:,:,1:noPositions-1) );

if d.events.noPositions(2)>2
    % large setsize
    noPositions= noPositionsSmallLarge(2);     
    fix = [0 0];
    stepAngle = 360/noPositions;
    objs = deg2vec( convertAngles( [stepAngle:stepAngle:360] )' ) .* radius ;
    objs(:,1) = objs(:,1) + fix(:,1);
    objs(:,2) = objs(:,2) + fix(:,2);
    %make last the first and add fixcross 
    d.objectsLarge = [objs(noPositions,:); objs(1:noPositions-1,:); fix];
    % Field Ring
    shoot = [radius*0.2 radius*0.4];
    d.objectFieldsLarge = makeFieldRing(fix, radius, shoot, stepAngle);
    d.objectFieldsLarge = cat(3, d.objectFieldsLarge(:,:, noPositions), d.objectFieldsLarge(:,:,1:noPositions-1) );
else
    d.events.noPositions(2) =[];
end


runningTime = 1000;
%reading ASL file
if (HeadIntegration>0)
      [d.eyes evt] = readAslFileSimple([d.info.files.path '\' d.info.files.eyeName]);
else
   disp('  It works only with head inegration, so far!');
   beep;
   return
end

%change y sign
% d.eyes.data.gaze(:,2) = -d.eyes.data.gaze(:,2);


%%%
% make trials
%%%
%make trailswise

d.analysed.varNames = { 'subNum', %1
           'cond', %2 
           'trNum', %3
           'fixOn', %4
           'tarOn', %5
           'stimOn', %6
           'stimOff', %7
           'tarPos', %8
           'tarType', %9
           'gtst' %10
           'isTrial', %11
       };
       
%onset codes
ITI = 128;
fixcross = 129;
cue = 130;
target = 131;
calibration = 132;
end_ = 0;


mtx = [];
trCnt =0;
lastEvt = -9;

for x=2:length(evt)
    if evt(x) ~= lastEvt
        lastEvt = evt(x); 
        switch ( evt(x) );
        case ITI
           trCnt= trCnt+1;
        case fixcross
            mtx(trCnt, 1) = x;
        case cue
            mtx(trCnt, 2) = x;
        case target
            mtx(trCnt, 3) = x;
        case calibration
            mtx(trCnt, 1:3) = NaN;
        end % case
    end% if
end% for

%covert linenumber in times
mtx(isnan(mtx))  = 1;
mtx(find(mtx==0))= 1;
mtx(:,1) = d.eyes.data.tStamps(mtx(:,1));
mtx(:,2) = d.eyes.data.tStamps(mtx(:,2));
mtx(:,3) = d.eyes.data.tStamps(mtx(:,3));
idx = find(mtx==0);
if ~isempty(idx)
    mtx(idx) = NaN;
end;

disp(['  found trials: ' num2str(size(d.events.stimuli,1)) ...
        ' (.dat) and ' num2str(size(mtx,1)) ' (.asc)']) 
%tarPos and stimType and tri file 
d.analysed.trials(:,8:9 ) = d.events.stimuli(:, max(noPositionsSmallLarge)+1:max(noPositionsSmallLarge)+2 ); 
d.analysed.trials(:,4:6) = mtx;
d.analysed.trials(:,7) = d.analysed.trials(:,6) +stimulusDuration;
d.analysed.trials(:,1) = subNum;
d.analysed.trials(:,2) = condition;
d.analysed.trials(:,3) = [1:size(d.analysed.trials,1)]';
d.analysed.trials(:,10)= 1;

%find calibration trials
d.analysed.trials(:,11)= 1; % all trials
x = find(isnan( mtx(:,1) ) );
d.analysed.trials(x,11)= 0; 

% if 4,5,6 is NaN then bad trial
idx = find ( sum( isnan( d.analysed.trials(:,4:6) ),2 ) > 0 );
d.analysed.trials(:,10) = 0;

if ~isempty(snd)
    soundCol = 16;
    d.analysed.trials(:,soundCol)= snd;
    d.analysed.varNames(end+1:16) = cellstr('');
    d.analysed.varNames(soundCol)= cellstr('sound');
end

%%%
%preprocessing data
%%%
disp('- preprocessing data');


%filtering
d.eyes.info.filters.butter.cutOff = 20;
d.eyes.info.filters.butter.order = 4;
d.eyes.data.gazeFil = myLowpassFilter(d.eyes.data.gaze...
                                    , d.eyes.info.rate...
                                    , d.eyes.info.filters.butter.cutOff...
                                    , d.eyes.info.filters.butter.order);


%%
%analyse
%%%
disp('- analysing movements');

% (status & velocity)
[d.eyes.data.status d.analysed.velocity] =  ...
    analyseEyeMovements(d.eyes.data.gazeFil(:,:,1), d.eyes.info.rate, [50 0.005]);


d.analysed.accel = gradient(d.analysed.velocity, 1/d.eyes.info.rate);

%%%
%saving
%%%
eval([filename ' = d;'])
disp(['- save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);
eval(['save(' '''' path '\' filename '.mat' '''' ' , ' '''' filename '''' ');']);


diary off;

aaveProcessData(d.info.files.filename);


%------------------------------------------------------------------

function stimuli=findThe9(stimuli)
%  fix problem with stimulus representation in variable size size
%  find the nine in all lines [:,1:end-2]
%  and adds position it [:,end-1] 
disp('  find the 9');
for c=1:size(stimuli, 1)
    x = find(stimuli(c,1:end-2)==9);
    if ~isempty(x)
        stimuli(c, end-1) = x(1);
    else
        %disp([' no 9 in trail ' num2str(c) '?']); 
        stimuli(c, end-1)  = 0; % catch
    end
end




% --- Executes during object creation, after setting all properties.
function edPositions2_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%------------------------------------------------------------------
function outfilename = convertTextFile(file)
% point.wav -> 1, grasp.wav -> 2
% it's needed, because matlabs import function can't reading data and text
% in on matrix 

% and fixes problem with large files

outfilename = 'visu.tmp';

disp(['  converting ' file ' -> ' outfilename ]);
fid=fopen(file, 'r');
c = 0;
txt={};
while 1
    c=c+1;
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    txt(c) = cellstr(tline);
end
fclose(fid);

fid=fopen(outfilename, 'w');
for c=1:length(txt)
    str = char(lower(txt(c)));
    x = strfind(str ,'point.wav');
    if ~isempty(x)
        str(x) = '1';
        str(x+1:x+8)=[];
    else 
        x = strfind(str ,'grasp.wav');
        if ~isempty(x)
            str(x) = '2';
            str(x+1:x+8)=[];
        end
    end
    fprintf(fid,'%s\n',str); 
end
fclose(fid);
