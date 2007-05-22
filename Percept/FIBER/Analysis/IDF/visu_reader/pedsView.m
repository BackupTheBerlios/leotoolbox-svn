function varargout = pedsView(varargin)
% PEDSVIEW Application M-file for pedsView.fig
%    FIG = PEDSVIEW launch pedsView GUI.
%    PEDSVIEW('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 23-Feb-2005 20:41:16

if nargin <= 1  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    guidata(fig, handles);

    if nargout > 0
		varargout{1} = fig;
	end
    
    clearFigure(handles); 
    if nargin == 1
        handles.data = varargin{1};
        handles.filename = NaN;
        handles.path = NaN;
        guiData(handles.mainFig, handles);
        refresh(handles);
    end    
       

    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
        if strcmp(varargin(1), 'close_me')==1
            handles = guidata(gcbo);
            %rtn = handles.data;
            close(handles.mainFig);
            return;
        end
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end

% --------------------------------------------------------------------
function clearFigure(handles);
	ch = '-';
    set(handles.t1,'String',ch);
    set(handles.t2,'String',ch);
    set(handles.t3,'String',ch);
    set(handles.t4,'String',ch);
    set(handles.t5,'String',ch);
    set(handles.t6,'String',ch);
    set(handles.t7,'String',ch);
    set(handles.t8,'String',ch);
    set(handles.t9,'String',ch);
    set(handles.t10,'String',ch);
    set(handles.t11,'String',ch);
    set(handles.t12,'String',ch);
    set(handles.t13,'String',ch);
    set(handles.t14,'String',ch);
    set(handles.t15,'String',ch);
    set(handles.t16,'String',ch);
    set(handles.t17,'String',ch);
    set(handles.t18,'String',ch);
    set(handles.t19,'String',ch);
    set(handles.t20,'String',ch);
    set(handles.t21,'String',ch);
    set(handles.t22,'String',ch);
    set(handles.t24,'String',ch);
    set(handles.t25,'String',ch);
    set(handles.t26,'String',ch);
    set(handles.t27,'String',ch);
    set(handles.t29,'String',ch);
    set(handles.t30,'String',ch);
    set(handles.mainFig,'Name','PedsView');
    handles.data = [];
    handles.filename = '';
    handles.path = '';
    guiData(handles.mainFig, handles);


% --------------------------------------------------------------------
function varargout = save_Callback(h, eventdata, hdl, varargin)

if isnan(hdl.filename)
    return
end

[filename path] = uiputfile([hdl.path hdl.filename]);
[p,name,ext,ver] = fileparts(filename);
hdl.data.info.files.filename = name;

eval([name '= hdl.data;']);
eval(['save(' '''' path filename '''' ', ' '''' name '''' ');']);

hdl.filename = filename;
hdl.path     = path;
refresh(hdl);
guiData(hdl.mainFig, hdl);




% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, hdl, varargin)

clearFigure(hdl);
[hdl.filename hdl.path] =uigetfile('*.mat','Pick a mat-file');
loadType = 0;
if get(hdl.cbRawData, 'value')
    loadType =1;
end
if get(hdl.cbFilData, 'value')
    loadType = loadType + 2;
end
hdl.data = loadPed([ hdl.path  hdl.filename], loadType);
refresh(hdl);
guiData(hdl.mainFig, hdl);
set(hdl.btSave, 'Enable', 'On');

% --------------------------------------------------------------------
function varargout = refresh(hdl)

set(hdl.mainFig,'Name', ['PedsView:     ' hdl.data.info.files.filename '  ' hdl.data.info.expName]);

set(hdl.t1,'String',[hdl.data.info.expName]);
set(hdl.t2,'String',[hdl.data.info.date]);
set(hdl.t3,'String',[hdl.data.info.notes]);

set(hdl.t4,'String',[hdl.data.info.files.path]);
set(hdl.t5,'String',[hdl.data.info.files.filename]);
set(hdl.t6,'String',[hdl.data.info.files.calName]);
set(hdl.t7,'String',[hdl.data.info.files.eyeName]);
set(hdl.t8,'String',[hdl.data.info.files.birdName]);
set(hdl.t9,'String',[hdl.data.info.files.evtName]);

set(hdl.t10,'String',[hdl.data.info.subject.number]);
set(hdl.t11,'String',[hdl.data.info.subject.sex]);
set(hdl.t12,'String',[hdl.data.info.subject.handed]);
set(hdl.t13,'String',[hdl.data.info.subject.notes]);

%birds
set(hdl.t14,'String',[hdl.data.birds.info.nrBirds]);
set(hdl.t15,'String',[hdl.data.birds.info.rate]);
set(hdl.t16,'String',[hdl.data.birds.info.nrSamples ]);

set(hdl.t17,'String',[num2str(size(hdl.data.birds.data.pos,1)) 'x' num2str(size(hdl.data.birds.data.pos,2)) 'x' num2str(size(hdl.data.birds.data.pos,3)) ]);
set(hdl.t18,'String',[num2str(size(hdl.data.birds.data.posFil,1)) 'x' num2str(size(hdl.data.birds.data.posFil,2)) 'x' num2str(size(hdl.data.birds.data.posFil,3))]);
set(hdl.t19,'String',[num2str(size(hdl.data.birds.data.rot,1)) 'x' num2str(size(hdl.data.birds.data.rot,2)) 'x' num2str(size(hdl.data.birds.data.rot,3))]);
set(hdl.t20,'String',[num2str(size(hdl.data.birds.data.rotFil,1)) 'x' num2str(size(hdl.data.birds.data.rotFil,2)) 'x' num2str(size(hdl.data.birds.data.rotFil,3))]);
set(hdl.t21,'String',[num2str(size(hdl.data.birds.data.tStamps,1)) 'x' num2str(size(hdl.data.birds.data.tStamps,2)) 'x' num2str(size(hdl.data.birds.data.tStamps,3))]);
set(hdl.t22,'String',[num2str(size(hdl.data.birds.data.status,1)) 'x' num2str(size(hdl.data.birds.data.status,2)) 'x' num2str(size(hdl.data.birds.data.status,3))]);

%eyes
set(hdl.t29,'String',[hdl.data.eyes.info.rate]);
set(hdl.t30,'String',[hdl.data.eyes.info.nrSamples ]);

set(hdl.t24,'String',[num2str(size(hdl.data.eyes.data.gaze,1)) ' x ' num2str(size(hdl.data.eyes.data.gaze,2))]);
set(hdl.t25,'String',[num2str(size(hdl.data.eyes.data.gazeFil,1)) ' x ' num2str(size(hdl.data.eyes.data.gazeFil,2))]);
set(hdl.t26,'String',[num2str(size(hdl.data.eyes.data.tStamps,1)) ' x ' num2str(size(hdl.data.eyes.data.tStamps,2))]);
set(hdl.t27,'String',[num2str(size(hdl.data.eyes.data.status,1)) ' x ' num2str(size(hdl.data.eyes.data.status,2))]);

if isfield(hdl.data, 'analysed')
     txt = strvcat('');
     if isfield(hdl.data.analysed, 'varNames')
         for x=1:length( hdl.data.analysed.varNames )
            
             if iscellstr(hdl.data.analysed.varNames(x))==0
                 hdl.data.analysed.varNames(x) = {'_'};
             end;
                   
            txt = strcat(txt, [ char(hdl.data.analysed.varNames(x))] );
            txt = strcat(txt, [ '|     |'] );
         end
     end
     if isfield(hdl.data.analysed, 'trials')
       for x=1:size(hdl.data.analysed.trials,1)
           txt = strvcat(txt, [num2str(hdl.data.analysed.trials(x,:))] );
       end
    end
else
    txt = 'no trialwise matrix';
end
set(hdl.listbox,'String', txt);

% --------------------------------------------------------------------
function varargout = t1_Callback(h, eventdata, hdl, varargin)
hdl.data.info.expName = get(hdl.t1,'String');
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = t2_Callback(h, eventdata, hdl, varargin)
hdl.data.info.date = get(hdl.t2,'String');
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = t3_Callback(h, eventdata, hdl, varargin)
hdl.data.info.notes = get(hdl.t3,'String');
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = t4_Callback(h, eventdata, hdl, varargin)
hdl.data.info.files.path = get(hdl.t4,'String'); 
guiData(hdl.mainFig, hdl);


% --------------------------------------------------------------------
function varargout = t10_Callback(h, eventdata, hdl, varargin)
hdl.data.info.subject.number = str2Num(get(hdl.t10,'String'));
guiData(hdl.mainFig, hdl);
refresh(hdl);

% --------------------------------------------------------------------
function varargout = t11_Callback(h, eventdata, hdl, varargin)
hdl.data.info.subject.sex = get(hdl.t11,'String'); 
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = t12_Callback(h, eventdata, hdl, varargin)
hdl.data.info.subject.handed = get(hdl.t12,'String');
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = t13_Callback(h, eventdata, hdl, varargin)
hdl.data.info.subject.notes = get(hdl.t13,'String');
guiData(hdl.mainFig, hdl);






% --------------------------------------------------------------------
function varargout = puPlot_Callback(h, eventdata, hdl, varargin)

select = get(hdl.puPlot, 'Value');
switch (select)
case 2
    xyz = hdl.data.birds.data.pos;
    t = hdl.data.birds.data.tStamps;
case 3
    xyz = hdl.data.birds.data.posFil;
    t = hdl.data.birds.data.tStamps;
case 4
    xyz = hdl.data.eyes.data.gaze;
    t = hdl.data.eyes.data.tStamps;
case 5
    xyz = hdl.data.eyes.data.gazeFil;
    t = hdl.data.eyes.data.tStamps;
    
case 6
    xyz = hdl.data.analysed.velocity;
    t = [1:length(xyz)];
otherwise
    xyz =[];
end



if ~isempty(xyz)
        %figure;
        %plot(t, xyz(:,:,m) );
        showData(t, xyz(:,:,:) );
        %title(['# ' num2str(m) ]);
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ListBox.
function ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListBox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes on button press in cbRawData.
function cbRawData_Callback(hObject, eventdata, handles)
% hObject    handle to cbRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbRawData


% --- Executes on button press in cbFilData.
function cbFilData_Callback(hObject, eventdata, handles)
% hObject    handle to cbFilData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbFilData


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, hdl)

[filename, pathname] = uiputfile({'*.txt';}, 'Save as');

format = '%6.4f';
missing = [' '];

fid = fopen([pathname filename] ,'w');

for co=1:length(hdl.data.analysed.varNames);
      fprintf(fid,[char(hdl.data.analysed.varNames(co)) ' \t']);
end
fprintf(fid,'\n');

for z = 1:size(hdl.data.analysed.trials,1)
   
   for co = 1:size(hdl.data.analysed.trials,2)
       cl = hdl.data.analysed.trials(z,co);
       if ~isnan(cl)
           fprintf(fid, [format '\t'],cl);
       else
           fprintf(fid,[missing ' \t']);
       end
   end
   fprintf(fid,'\n');

end;
fclose(fid);
disp(['  matrix exported: ' pathname filename ]);