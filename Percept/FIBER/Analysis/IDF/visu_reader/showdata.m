function varargout = showdata(varargin)
% SHOWDATA Application M-file for showdata.fig
%    FIG = SHOWDATA launch showdata GUI.
%    SHOWDATA('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 11-Jul-2002 14:37:08

if nargin == 2  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

   handles.xVal = varargin{1};
   handles.yVal = varargin{2};
   if isempty(handles.xVal)
         handles.xVal = [1:size(handles.yVal,1)]';
   end        

    handles.minStep = 0.01;
    set(handles.slider, 'SliderStep', [handles.minStep 0.05] );

    handles.minMax = [min( handles.yVal(:) ) max( handles.yVal(:) )];
    handles.plotLength = length( handles.xVal );
    handles.windowSize = floor( handles.plotLength * handles.minStep) - 1;
    set(handles.slider, 'Max', handles.plotLength - handles.windowSize -1 );

    if handles.plotLength <= 4000
            handles.windowSize = 4000-1;
            set(handles.slider, 'SliderStep', [1 1] );
            set(handles.slider, 'Max', 1);
    end
    guiData(handles.mainFig, handles);
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK


    
    try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


% --------------------------------------------------------------------
function varargout = slider_Callback(h, eventdata, hdl, varargin)
draw(hdl);


% --------------------------------------------------------------------
function draw(hdl)
from = floor(get(hdl.slider ,'Value') ) + 1;
to = from + hdl.windowSize;

set( hdl.txtInfo , 'String', [ num2str(from) ':' num2str(to) ...
        '   (of ' num2str(hdl.plotLength) ')' ] );
    
axes(hdl.axes1);
plot( hdl.xVal( from:to ),  hdl.yVal( from: to,: ) );
hold on;
plot( [hdl.xVal(from) hdl.xVal(to)] ,[0 0],':','Color', [.5 .5 .5]);
hold off;
set(hdl.axes1,'YLim',  hdl.minMax   );

drawnow;


