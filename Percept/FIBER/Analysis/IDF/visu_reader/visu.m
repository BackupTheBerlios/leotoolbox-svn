function varargout = visu(varargin) 
% VISU Application M-file for visu.fig
%    FIG = VISU launch visu GUI.
%    VISU('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 30-Jun-2004 20:34:10

%FIXME STATUS CODES

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);

    handles.firstFixObject = 12;
    handles.firstFixX = 13;
    handles.firstFixY = 14;
    guidata(fig, handles);

    bg = [.0 .0 .0];
    axcol = [.3 .3 .3];
    axes(handles.axes1);
    %axis ([5 30 0 25]);
    set(gca,'xcolor',axcol,'ycolor',axcol, 'color',bg);   

    set(handles.axes1, 'XGrid', 'off' , 'YGrid', 'off');
    set(handles.axes2, 'XGrid', 'on' , 'YGrid', 'on');
    set(handles.axes3, 'XGrid', 'on' , 'YGrid', 'on', 'XAxisLocation','top');
    
    axes(handles.axes2);hold on;
    set(gca,'xcolor',axcol,'ycolor',axcol, 'color',bg);   
    axes(handles.axes3);hold on;
    set(gca,'xcolor',axcol,'ycolor',axcol, 'color',bg);   

    set(handles.mainFig,'Name',['VISU 3']);

    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


% --------------------------------------------------------------------
function varargout = pedsViewData(h, eventdata, hdl, varargin)
pedsView(hdl.d);

% --------------------------------------------------------------------
function varargout = muLoadData(h, eventdata, hdl, varargin)
[hdl.filename hdl.path] =uigetfile('*.mat','Pick a mat-file with ASL data');
[p,filename,ext,ver] = fileparts(hdl.filename);
tmp = load([hdl.path filename]);
eval(['hdl.d = tmp.' filename ';']);

hdl.currTrial = 0;

if size(hdl.d.analysed.trials,2) <= 10
    hdl.d.analysed.trials(:,11:13) = NaN;
end

set(hdl.mainFig,'Name',['Visu: ' hdl.d.info.files.filename]);

guiData(hdl.mainFig, hdl);

set(hdl.txtNrTrials, 'String', num2str(size(hdl.d.analysed.trials,1)));
btNext(gcbo,[],guidata(gcbo));

% --------------------------------------------------------------------
function btSaveExit_Callback(hObject, eventdata, hdl)
[filename path] = uiputfile([hdl.path hdl.filename]);
if filename ~= 0
    [p,name,ext,ver] = fileparts(filename);
    hdl.d.info.files.filename = name;
    hdl.d.info.files.path = path; 
    eval([name '= hdl.d;']);
    eval(['save(' '''' path filename '''' ', ' '''' name '''' ');']);
end
hdl.newfilename = cellstr([path filename]);
guiData(hdl.mainFig, hdl);

% --------------------------------------------------------------------
function varargout = btPrev(h, eventdata, hdl, varargin)
hdl.currTrial = hdl.currTrial-1;
if hdl.currTrial < 1
    beep;
else
    guiData(hdl.mainFig, hdl);
    drawTrial(hdl);
end

% --------------------------------------------------------------------
function varargout = btNext(h, eventdata, hdl, varargin)
hdl.currTrial = hdl.currTrial+1;
if hdl.currTrial > size(hdl.d.analysed.trials,1)
    beep;
else 
    guiData(hdl.mainFig, hdl);
    drawTrial(hdl);
end


% --------------------------------------------------------------------
function varargout = togglebutton1_Callback(h, eventdata, hdl, varargin) %gtst
hdl.d.analysed.trials(hdl.currTrial,10) = abs(hdl.d.analysed.trials(hdl.currTrial,10)-1);
guiData(hdl.mainFig, hdl);
refreshGoodTrialBtn(hdl);

% --------------------------------------------------------------------
function refreshGoodTrialBtn(hdl)
if hdl.d.analysed.trials(hdl.currTrial,10)
    col = get(hdl.mainFig,'Color');
    set(hdl.tgGtst, 'String', 'good trial', 'Value', 1, 'BackgroundColor', col);
    
else
    set(hdl.tgGtst, 'String', 'bad trial', 'Value', 0, 'BackgroundColor','r');
end;

% --------------------------------------------------------------------
function drawStimBoard(hdl); % wich trial
axes(hdl.axes1);


if hdl.d.analysed.trials(hdl.currTrial, 11) == 0 % is calibration
     plot(hdl.d.calibration(:,1),hdl.d.calibration(:,2),'o',...
         'MarkerSize',[10], 'MarkerEdgeColor',[.4 .4 .4]); 
    return;
end

[n, objects, objectFields] = getObjects(hdl); % adapt set size
 

if 1
     plot(objects(1:n,1),objects(1:n,2),'.', 'MarkerSize',[2], 'Color',[.9 .9 .9] );
     plot(objects(n+1,1),objects(n+1,2),'w+', 'MarkerSize',[8]);
end

if isField(hdl.d, 'objectFields')
    for m=1:size(objectFields,3)
        plot( objectFields(:,1,m), objectFields(:,2,m),':',...
         'Color',[.3 .5 .3] ); 
    end
    
    
end

if get(hdl.cbObjects, 'Value')
    %fixation point
    fix = hdl.d.analysed.trials(hdl.currTrial,hdl.firstFixObject);
    if ~isnan(fix)
        plot( [objectFields(:,1,fix); objectFields(1,1,fix)],...
            [objectFields(:,2,fix); objectFields(1,2,fix)],':',...
                'LineWidth',2,'Color','y'  ); 
%         plot([objects(17,1) objects(fix,1) ],...
%              [objects(17,2) objects(fix,2) ],'LineWidth', 2, 'Color',[.8 .8 .8]  );
        
        %plot(objects(fix,1),objects(fix,2),'ro', 'MarkerSize',[20],...
        %    'MarkerFaceColor',[.8 .8 .8],'MarkerEdgeColor',[0 0 0]);
    end
    
    plot(hdl.d.analysed.trials(hdl.currTrial, hdl.firstFixX), hdl.d.analysed.trials(hdl.currTrial, hdl.firstFixY), ...
        'o','MarkerSize',[10],'MarkerFaceColor','y','MarkerEdgeColor','k')
    
    %target
    idx = find( hdl.d.events.stimuli( hdl.currTrial, 1:n ) == 9 );
    plot( objects(idx,1), objects(idx,2),'h', 'MarkerSize',[10],...
            'MarkerFaceColor',[0 1 0],'MarkerEdgeColor',[0 1 0]);
  
    %errors
    errorCode = [1:7];
    out ={'o';'c';'s';'oc';'os';'cs';'x'};
    
    for x=1:length(errorCode)
        idx = find( hdl.d.events.stimuli( hdl.currTrial, 1:n ) == errorCode(x) );
        text( objects(idx,1), objects(idx,2), out( errorCode(x) ), ...
            'FontSize',[15],...
            'HorizontalAlignment','center',...
            'FontWeight','bold','Color',[.8 .8 .8]);
    end
        
end

% --------------------------------------------------------------------
function drawTrial(hdl); % wich trial

watchon;
%find line
fromTime = hdl.d.analysed.trials(hdl.currTrial,4);
hdl.from = findTimeStamps(hdl.d.eyes.data.tStamps, fromTime,1);

if hdl.currTrial == size(hdl.d.analysed.trials,1) %last one
     hdl.to = size(hdl.d.eyes.data.gazeFil,1);
else
     toTime = hdl.d.analysed.trials(hdl.currTrial+1,4);
     if isnan(toTime)
         toTime = fromTime + 5;
     end
     hdl.to = findTimeStamps(hdl.d.eyes.data.tStamps, toTime,1);
end
% display just till stimOffset  
    if get(hdl.cbTillOffset, 'Value') & hdl.d.analysed.trials(hdl.currTrial,11)==1
        fromTime = hdl.d.analysed.trials(hdl.currTrial, 5);
        toTime = hdl.d.analysed.trials(hdl.currTrial, 7);
    else % calibration trial ?
        if hdl.currTrial>1
            fromTime = hdl.d.analysed.trials(hdl.currTrial-1, 7);
        else
            fromTime = 0;
        end
        if hdl.currTrial<size(hdl.d.analysed.trials,1)
            toTime = hdl.d.analysed.trials(hdl.currTrial+1, 5);
        else
            toTime = max( hdl.d.eyes.data.tStamps );
        end
    end

    
hdl.from  = findTimeStamps(hdl.d.eyes.data.tStamps, fromTime,1);
hdl.to = findTimeStamps(hdl.d.eyes.data.tStamps, toTime,1);

set(hdl.edtCurrTrial,'String', num2str(hdl.currTrial));
set(hdl.edtTo,'String', num2str(hdl.to));
set(hdl.edtFrom,'String', num2str(hdl.from));


axes(hdl.axes2);cla;
axes(hdl.axes3);cla;
axes(hdl.axes1);cla;

hdl.markerLine =[];
set(hdl.btDelete,'Enable','off');
set(hdl.btCut,'Enable','off');

if get(hdl.tgZoom, 'Value')
    tmp = get(hdl.mainFig,'Color');
    set(hdl.tgZoom, 'Value',0, 'BackgroundColor', tmp);
end



% if ~isnan(fromTime )
    drawStimBoard(hdl);
    drawEyeMovement(hdl);
    refreshGoodTrialBtn(hdl);
    %upDateErrorBtns(hdl);
% else
%     beep;
% end
guiData(hdl.mainFig, hdl);
watchoff;


% --------------------------------------------------------------------
function varargout = edtCurrTrial_Callback(h, eventdata, hdl, varargin)
tmp = str2num( char( get(hdl.edtCurrTrial, 'String') ));

if isempty(tmp) | tmp<1 
   beep;
   set(hdl.edtCurrTrial, 'String', int2str(hdl.currTrial));
else   
       if tmp > size(hdl.d.analysed.trials,1)
           hdl.currTrial = size(hdl.d.analysed.trials,1); 
       else
           hdl.currTrial = tmp;
       end
       guiData(hdl.mainFig, hdl);
       drawTrial(hdl);
end


% --------------------------------------------------------------------
function drawEyeMovement(hdl);
t  = hdl.d.eyes.data.tStamps(hdl.from:hdl.to);
xy = hdl.d.eyes.data.gazeFil(hdl.from:hdl.to,:); 
st = hdl.d.eyes.data.status(hdl.from:hdl.to);

[n, objects, objectFields] = getObjects(hdl); %adapt set size

if get(hdl.cbAdjust,'Value') & hdl.d.analysed.trials(hdl.currTrial,11)==1 % adjust at target onset
    tarTime = hdl.d.analysed.trials(hdl.currTrial,5);
    adjust = hdl.d.eyes.data.gazeFil( findTimeStamps(hdl.d.eyes.data.tStamps, tarTime, 1), : )...
        - objects(n+1,:);
    xy(:,1) = xy(:,1) - adjust(1);
    xy(:,2) = xy(:,2) - adjust(2);
end

%AXES1
axes(hdl.axes1);
plot(xy(1,1), xy(1,2) ,['ko-'], 'MarkerSize',[6],'MarkerFaceColor',[.0 .7 .0]);
plot(xy(end,1), xy(end,2) ,['ko-'], 'MarkerSize',[6],'MarkerFaceColor', [.7 .0 .0]);
plot(xy(:,1), xy(:,2) ,['b.-'], 'MarkerSize',[1],'MarkerEdgeColor','c');

if get(hdl.popAxes2,'Value') >= 2 %AXES2
    axes(hdl.axes2);
    plot([t(1) t(end)], [min(min(xy)) max(max(xy))] , 'k.'); %to adjust axis
    if get(hdl.popAxes2,'Value') == 3 
        %plot markers
        idx = find(st == 3 | st== 4); %on- & offsets
        if hdl.d.analysed.trials(hdl.currTrial, 11) == 0 
            text(t(2), max(max(xy))/2, ['        That''s a calibration!'], 'Color','w', 'FontWeight','bold');
            idx =[];
        end
        if ~isempty(idx)
            if st(idx(1)) == 4 %starts with offset
                idx(1)=[];
            end
            for m=1:2:length(idx)-1
                area( [t(idx(m)) t(idx(m+1))] , max(get(hdl.axes2,'Ylim'))*[1 1], ...
                                min(get(hdl.axes2,'Ylim')), 'FaceColor', [.3 .1 .1],...
                                'EdgeColor',[.4 .4 .4] );
            end
        end
    end
    %lines 
    plot(t, xy(:,1), 'y');
    plot(t, xy(:,2), 'g');
end

if get(hdl.popAxes3,'Value') >= 2  %AXES3
    evtTimes = hdl.d.analysed.trials(hdl.currTrial,5:7);
    %evtTimes = evtTimes(2:4) ;
    if get(hdl.tgZoom,'Value') ~= 1
        vertLines(evtTimes, [.8 .8 .8], [hdl.axes2],hdl.d.analysed.varNames(5:7)); %event
    end

    %velocity
    axes(hdl.axes3); 
    if get(hdl.popAxes3,'Value') == 3 %acceleration
        v  = hdl.d.analysed.accel(hdl.from:hdl.to);
        plot(t, v, 'y.-');
    else
        v  = hdl.d.analysed.velocity(hdl.from:hdl.to);

        area(t, v, 'FaceColor', 'r', 'EdgeColor','k');
    end

    if length(find(st == 3 | st== 4)) <= 100
        %vertlines
        idx = find(st == 3); %onset
        vertLines( t(idx), [.2 .7 .2], [hdl.axes3] ); 

        idx = find(st == 4); %offset
        vertLines( t(idx), [.7 .2 .2], [hdl.axes3] ); 

        idx = find(st == 0); %ambiguous
        vertLines( t(idx), [.4 .4 .4], [hdl.axes3] ); 
    end
end


% --------------------------------------------------------------------
function varargout = popAxes2_Callback(h, eventdata, hdl, varargin)
drawTrial(hdl);


% --------------------------------------------------------------------
function varargout = popAxes3_Callback(h, eventdata, hdl, varargin)
drawTrial(hdl);


% --------------------------------------------------------------------
function varargout = btSelect(h, eventdata, hdl, varargin)

xyMarker =[];
tmpHdl = [];
while (1)
    [x,y,bt] =ginput(1);
    if bt == 1 | bt == 3
        xl = str2num(get(hdl.axes2, 'XTickLabel'));
        yl = str2num(get(hdl.axes2, 'YTickLabel'));
        if  xl(1)<= x & xl(end)>=x & yl(1)<= y & yl(end)>=y & strcmp(get(gca, 'tag'), 'axes2') == 1
            xyMarker = [xyMarker; x y];
        else
            break;
        end
        if bt == 1 
            break;
        else
            if size(xyMarker,1) == 1
                axes(hdl.axes2);
                tmpHdl = plot(xyMarker(1,1)*[1 1],get(gca,'Ylim'),'w.-'); 
            else
                break
            end
        end
    end
end
delete(tmpHdl);

if isempty(xyMarker)
    return
elseif size(xyMarker,1) == 2 %two clicks
    if xyMarker(2,1) < xyMarker(1,1)
        xyMarker = [ xyMarker(2,:); xyMarker(1,:)]; %swap marker
    end
end

hdl.markerIdx =[];

from = str2num( get(hdl.edtFrom,'String') );
to = str2num( get(hdl.edtTo,'String') );

click1 =  findTimeStamps(hdl.d.eyes.data.tStamps,  xyMarker(1,1),1);

if size(xyMarker,1) == 2
    click2 =  findTimeStamps(hdl.d.eyes.data.tStamps,  xyMarker(2,1),1);
    idx = [click1 click2];
else
    idx = max( find(hdl.d.eyes.data.status(from:click1-1) == 3 | hdl.d.eyes.data.status(from:click1-1) == 4) );
    idx = [idx  min( find(hdl.d.eyes.data.status(click1:to) == 3 | hdl.d.eyes.data.status(click1:to) == 4) )];
    if length(idx) ==2 
        idx = idx + [from-1 click1-1];
    end
end

%select
if length(idx) == 2 
    axes(hdl.axes2);
    if ~isempty(hdl.markerLine)
        delete(hdl.markerLine)
    end;

   %plot marker
   t = hdl.d.eyes.data.tStamps(idx);
   tmp = str2num(get(hdl.axes2, 'YTickLabel'));
   y = [tmp(1) tmp(end)];
   hdl.markerLine = plot([t(1) t(1) t(2) t(2) t(1)], [y(1) y(2) y(2) y(1) y(1)],'mo-');
     
   
   %print infos
   max_vel = max(hdl.d.analysed.velocity( idx(1):idx(2) ));
   dist  = euclid_dist( hdl.d.eyes.data.gazeFil(idx(1),:), hdl.d.eyes.data.gazeFil(idx(2),:) );
   
   txt = strvcat('');
   txt = strvcat(txt, ['time              :   ' num2str( (t(2)-t(1))*1000 ) '  msec']);
   txt = strvcat(txt, ['distance       :   ' num2str( dist ) '  pt']);
   txt = strvcat(txt, ['max velocity :   ' num2str( max_vel ) ' ']);
   txt = strvcat(txt, ['']);
   txt = strvcat(txt, ['sample         :   ' num2str( idx(1) ) ' - ' num2str( idx(2) )]);
   set(hdl.bxInfo,'string',txt); 

   % marker
   hdl.markerIdx = idx;
   % enable buttons
   set(hdl.tgZoom,'Enable','on');
   if isempty( find( hdl.d.eyes.data.status( idx(1):idx(2) ) == 3 | ...
           hdl.d.eyes.data.status( idx(1):idx(2) ) == 4) )
       set(hdl.btCut,'Enable','on');
   else
       set(hdl.btCut,'Enable','off');
   end
   if size(xyMarker,1) == 1
       set(hdl.btDelete,'Enable','on');
   else
       set(hdl.btDelete,'Enable','off');
   end
end

guiData(hdl.mainFig, hdl);




% --------------------------------------------------------------------
function varargout = btDelete(h, eventdata, hdl, varargin) %delete
if ~isempty(hdl.markerLine)
    a =questdlg('Delete selection?','Delete selection?','Yes','No','No');
    if strcmp(a,'Yes') == 1
        if length(hdl.markerIdx) == 2
            if hdl.d.eyes.data.status(hdl.markerIdx(1)) == 3 % onset is left
                hdl.d.eyes.data.status( hdl.markerIdx(1):hdl.markerIdx(2)+1 ) = 2; % steady
            end
            if hdl.d.eyes.data.status(hdl.markerIdx(1)) == 4 % offset is left
                hdl.d.eyes.data.status( hdl.markerIdx(1):hdl.markerIdx(2)+1 ) = 1; % steady
            end
        end            
else
        return;
    end
    
    guiData(hdl.mainFig, hdl);
    drawTrial(hdl);
end




% --------------------------------------------------------------------
function varargout = tgZoom_Callback(h, eventdata, hdl, varargin)
if get(hdl.tgZoom,'Value') == 0
   tmp = get(hdl.btSelect,'BackgroundColor');
   set(hdl.tgZoom, 'BackgroundColor', tmp);
   drawTrial(hdl);
else
   if ~isempty(hdl.markerLine) & length(hdl.markerIdx) == 2
        %ZOOM
        set(hdl.tgZoom, 'BackgroundColor', 'g');
        delete(hdl.markerLine);
        hdl.markerLine =[];
        set(hdl.btDelete,'Enable','off');
        
        ext = round((hdl.to-hdl.from)*0.01);
        hdl.from = hdl.markerIdx(1)-ext ;
        hdl.to = hdl.markerIdx(2)+ext;
        guiData(hdl.mainFig, hdl);


        axes(hdl.axes2);cla;
        axes(hdl.axes3);cla;
        axes(hdl.axes1);cla;

        drawStimBoard(hdl);
        drawEyeMovement(hdl);
    else    
        set(hdl.tgZoom, 'Value',0);
    end
end
    
% --------------------------------------------------------------------
function varargout = btNextBad_Callback(h, eventdata, hdl, varargin)

idx = min(find( hdl.d.analysed.trials(hdl.currTrial+1:end,10) == 0));
if ~isempty(idx)
    hdl.currTrial = hdl.currTrial +idx;
    guiData(hdl.mainFig, hdl);
    drawTrial(hdl);
end



% --------------------------------------------------------------------
function varargout = btCut_Callback(h, eventdata, hdl, varargin)
% cut at minimum, ftn only useable within a movement
m = min( hdl.d.analysed.velocity(hdl.markerIdx(1):hdl.markerIdx(2)));
idx = find( hdl.d.analysed.velocity(hdl.markerIdx(1):hdl.markerIdx(2)) ==m );

idx = idx+ hdl.markerIdx(1) -1;

hdl.d.eyes.data.status(idx) = 0;
hdl.d.eyes.data.status(idx-1) = 4;
hdl.d.eyes.data.status(idx+1) = 3;
guiData(hdl.mainFig, hdl);
drawTrial(hdl);







% --------------------------------------------------------------------
function varargout = cbAdjust_Callback(h, eventdata, hdl, varargin)
drawTrial(hdl);
% --------------------------------------------------------------------
function varargout = cbCalPoints_Callback(h, eventdata, hdl, varargin)
drawTrial(hdl);

% --------------------------------------------------------------------
function varargout = cbTillOffset_Callback(h, eventdata, hdl, varargin)
drawTrial(hdl);


% 
% % --------------------------------------------------------------------
% function upDateErrorBtns(hdl)
% 
% errorType = hdl.d.analysed.trials(hdl.currTrial,11);
% set(hdl.tgCorrect, 'Value', 0, 'ForegroundColor', [0.5 .5 .5] ,...
%     'BackgroundColor',[.75 .75 .75]);
% set(hdl.tgColorEr, 'Value', 0, 'ForegroundColor', [0.5 .5 .5], ...
%     'BackgroundColor',[.75 .75 .75]);
% set(hdl.tgShapeEr, 'Value', 0, 'ForegroundColor', [0.5 .5 .5], ...
%     'BackgroundColor',[.75 .75 .75]);
% set(hdl.tgDoubleEr, 'Value',0, 'ForegroundColor', [0.5 .5 .5], ...
%     'BackgroundColor',[.75 .75 .75]);
% 
% if ~isnan(errorType)
%     switch (errorType)
%     case 1
%         highLightBtn = hdl.tgCorrect;
%     case 2
%         highLightBtn = hdl.tgColorEr;
%     case 3
%         highLightBtn = hdl.tgShapeEr;
%     case 4
%         highLightBtn = hdl.tgDoubleEr;
%     end
%     
%     set(highLightBtn, 'Value',1, 'ForegroundColor', [0 0 0] , ...
%     'BackgroundColor',[.95 .95 .95]);
% 
% end
% 
% 
% 
%     
% % --------------------------------------------------------------------
% function varargout = tgCorrect_Callback(h, eventdata, hdl, varargin)
% if get(hdl.tgCorrect, 'Value')
%     hdl.d.analysed.trials(hdl.currTrial,11) = 1;
% else
%     hdl.d.analysed.trials(hdl.currTrial,11) = NaN;
% end
% guiData(hdl.mainFig, hdl);
% upDateErrorBtns(hdl);
% 
% 
% 
% 
% % --------------------------------------------------------------------
% function varargout = tgColorEr_Callback(h, eventdata, hdl, varargin)
% if get(hdl.tgColorEr, 'Value')
%     hdl.d.analysed.trials(hdl.currTrial,11) = 2;
% else
%     hdl.d.analysed.trials(hdl.currTrial,11) = NaN;
% end
% guiData(hdl.mainFig, hdl);
% upDateErrorBtns(hdl);
% 
% 
% % --------------------------------------------------------------------
% function varargout = tgShapeEr_Callback(h, eventdata, hdl, varargin)
% if get(hdl.tgShapeEr, 'Value')
%     hdl.d.analysed.trials(hdl.currTrial,11) = 3;
% else
%     hdl.d.analysed.trials(hdl.currTrial,11) = NaN;
% end
% guiData(hdl.mainFig, hdl);
% upDateErrorBtns(hdl);
% 
% 
% % --------------------------------------------------------------------
% function varargout = tgDoubleEr_Callback(h, eventdata, hdl, varargin)
% if get(hdl.tgDoubleEr, 'Value')
%     hdl.d.analysed.trials(hdl.currTrial,11) = 4;
% else
%     hdl.d.analysed.trials(hdl.currTrial,11) = NaN;
% end
% guiData(hdl.mainFig, hdl);
% upDateErrorBtns(hdl);
% 
% 
%  
% --------------------------------------------------------------------
function varargout = btFixPoint_Callback(h, eventdata, hdl, varargin)

[x,y,bt] =ginput(1);

[n, objects] = getObjects(hdl);

currObj = ones(n,2)*NaN;
idx = find( hdl.d.events.stimuli( hdl.currTrial, 1:n ) > 0 );
currObj(idx,:) = objects(idx,1:2);
tmp = ones( n, 1) * [x y];
tmp = euclid_dist( currObj, tmp);;
m = min(tmp);

if m < 3
    select = find(tmp == m);
else
    select = NaN;
end

hdl.d.analysed.trials(hdl.currTrial,hdl.firstFixObject) = select;
guiData(hdl.mainFig, hdl);
drawTrial(hdl);


% --------------------------------------------------------------------
function varargout = axes1_ButtonDownFcn(h, eventdata, hdl, varargin)

btFixPoint_Callback(h, eventdata, hdl, varargin);


% --- Executes on button press in btNext.
function btNext_Callback(hObject, eventdata, handles)
btNext(hObject, eventdata, handles);


% --- Executes on button press in cbObjects.
function cbObjects_Callback(hObject, eventdata, hdl)
drawTrial(hdl);

% --- Executes on button press in btAscciOut.
function btAscciOut_Callback(hObject, eventdata, hdl)
btSaveExit_Callback(hObject, eventdata, hdl);
hdl = guidata(gcbo);


[p,name,ext,ver] = fileparts(char(hdl.newfilename));
filename = [name '.out'];
aaveAsciiOut(hdl.d, [hdl.d.info.files.path filename]);    


% --- Executes on button press in btSaveExit.


% --------------------------------------------------------------------
function Unfilter_Callback(hObject, eventdata, hdl)
hdl.d.eyes.data.gazeFil = hdl.d.eyes.data.gaze;
guiData(hdl.mainFig, hdl);
drawTrial(hdl);


% --------------------------------------------------------------------
function changeXsign_Callback(hObject, eventdata, hdl)
hdl.d.eyes.data.gaze(:,1) = -hdl.d.eyes.data.gaze(:,1);
hdl.d.eyes.data.gazeFil(:,1) = -hdl.d.eyes.data.gazeFil(:,1);
guiData(hdl.mainFig, hdl);
drawTrial(hdl);


% --------------------------------------------------------------------
function changeYsign(hObject, eventdata, hdl)
hdl.d.eyes.data.gaze(:,2) = -hdl.d.eyes.data.gaze(:,2);
hdl.d.eyes.data.gazeFil(:,2) = -hdl.d.eyes.data.gazeFil(:,2);
guiData(hdl.mainFig, hdl);
drawTrial(hdl);


% --------------------------------------------------------------------
function processData_Callback(hObject, eventdata, hdl)
% [filename path] =uigetfile('*.mat','Pick a mat-file');
btSaveExit_Callback(hObject, eventdata, hdl);
a = questdlg('Process the data again ?', 'Yes', 'Yes','No', 'No');
if strcmp(a, 'Yes') ==1
    aaveProcessData([hdl.d.info.files.path  hdl.d.info.files.filename]);
    beep;
end



% --------------------------------------------------------------------
function ShowTrialInfo_Callback(hObject, eventdata, hdl)
disp(['- Trial #' num2str(hdl.currTrial) ' -']);
for x=1:size(hdl.d.analysed.trials,2)
    fprintf('%3d  %s%s%6.2f\r\n', x, char(hdl.d.analysed.varNames(x)),': ',...
        hdl.d.analysed.trials(hdl.currTrial,x) );
end

% --------------------------------------------------------------------
function [n, objects, objectFields] = getObjects(hdl)
%adapts for different set sizes

objects = hdl.d.objects;    
objectFields = hdl.d.objectFields;
n = hdl.d.events.noPositions;
if length(n) > 1 % more than one set size
    n = hdl.d.analysed.trials(hdl.currTrial, 15);% setsize
     if n == max(hdl.d.events.noPositions) % big one
        objects = hdl.d.objectsLarge;
        objectFields = hdl.d.objectFieldsLarge;
     end
end

% --------------------------------------------------------------------
function rotateStim_Callback(hObject, eventdata, hdl)
% t..t <target type> <target pos>

for c=1:size(hdl.d.events.stimuli, 1)
    nPos = hdl.d.analysed.trials(c, 15);
    v = hdl.d.events.stimuli(c,1:nPos); % get positions
    v = [v(end) v(1:end-1)]; % flip positions
    hdl.d.events.stimuli(c, 1:nPos) = v;
    
    t = hdl.d.events.stimuli(c,end-1); % append target pos and target type
    t = t+1; % change target pos
    if (t > nPos) t =1; end
    hdl.d.events.stimuli(c,end-1) = t;
end

%change in trailwise file
hdl.d.analysed.trials(:,8) = hdl.d.events.stimuli(:,end-1);

guiData(hdl.mainFig, hdl);
drawTrial(hdl);
