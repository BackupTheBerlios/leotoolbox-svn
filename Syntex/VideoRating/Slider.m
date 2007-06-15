function [status ts] = Slider(commandstr, varargin)

% simple slider recorder
%
% USAGE: status=Slider(commandstr, varargin)


persistent sldr; % structure to hold slider settings

status=0;
ts=[];

if ~exist('commandstr', 'var') || isempty(commandstr)
    error([mfilename ' USAGE: status=Slider(commandstr, varargin)']);
end

ctime=GetSecs; % commandtime

if ~IsOSX && ~IsWin
    error('Sorry, this currently only works on OS/X and Windows.');
end


switch(lower(commandstr))
    case {'init'},

        sldr.numGamepads = Gamepad('GetNumGamepads')
        if sldr.numGamepads<=0
            disp( 'No Gamepads found');

            return;
        end
        sldr.gamepadIndex=1;
        sldr.numAxes = Gamepad('GetNumAxes', sldr.gamepadIndex);

        if sldr.numAxes< 1
            disp( 'No Axis found');

            return;
        end
        sldr.numButtons = Gamepad('GetNumButtons', sldr.gamepadIndex);

          sldr.axe=2; % y-axis
      sldr.axisMax=32767;
        sldr.axisMin=-32767;
        sldr.axisMid=0;

        % determined values for y-axis
        sldr.axisMax=24286;
        sldr.axisMin=-29684;
        sldr.axisMid=-1928;


        sldr.fudge=-1;

        if nargin>=1
            sldr.win=varargin{1};
        else
            sldr.win=max(Screen('Screens'));
        end

        sldr.ts0=GetSecs;


        % set plot values for slider
        insetSlider=10;
        xOffset=10;
        sizeSlider=5;
        lineSlider=2;
        [h v]=Screen('WindowSize', sldr.win);
        sldr.min=round(insetSlider/100*v);
        sldr.max=round((100-insetSlider)/100*v);
        sldr.mid=round(sldr.min+(sldr.max-sldr.min)/2);
        sldr.line=round(lineSlider/100*h);
        sldr.lineColor=[0 255 0];
        sldr.color=[255 0 0];
        sldr.background=GrayIndex(sldr.win);
        sldr.x=round(xOffset/100*v);
        sldr.width=3;

        sldr.count=0;
        sldr.size=round(sizeSlider/100*h);
        
        sldr.rect=[0 0 sldr.size sldr.size ]; 
        sldr.oldRect=[];
        % close any open logfile
        if isfield(sldr, 'logfp') && sldr.logfp>0
            fclose(sldr.logfp);
            sldr.logfp=0;
        end
        % open new logfile
        sldr.logfilename=[sldr.fullname '_log' '.txt'];
        sldr.logfp=fopen(sldr.logfilename,'a');
        if sldr.logfp<0
            error([mfilename ': error, unable to open slider log file: ' sldr.logfilename] );
        end
        % print movie name
        disp([mfilename ': Slider name: ' sldr.fullname sldr.extension]);
        disp([mfilename ': Logfilename: ' sldr.logfilename]);
        fprintf(sldr.logfp, 'Slider name: %s\n', sldr.fullname);
        fprintf(sldr.logfp, 'Logfilename: %s\n', sldr.logfilename);

        fprintf(sldr.logfp, [ mfilename ': initialized.\n']);
        disp([ mfilename ': initialized.\n']);
        fprintf(sldr.logfp, '%s\t%s\t%s\n', 'TIME', 'COUNT', 'VALUE' );

        sldr

    case 'message',

        sldr.ts=GetSecs-sldr.ts0;
        if isfield(sldr, 'logfp') && sldr.logfp>0
            fprintf(sldr.logfp, '%f MES %s\n', sldr.ts, varargin{1});
        else
            disp( [mfilename ':error printing message: log file not open.']);
        end
    case {'slidername', 'logfilename' },
        sldr.name=varargin{1};
        sldr.extension='.txt';
        sldr.fullname=[sldr.dir filesep sldr.name];
        i=0;

        temp=sldr.fullname;
        while 2==exist([temp  sldr.extension]) % if file already exists, add a number until file does not exist
            i=i+1;
            temp=[sldr.fullname num2str(i)];
        end
        sldr.fullname=temp;

    case {'sliderdir', 'logfiledir'},
        sldr.dir=varargin{1};
        makedir(sldr.dir);

    case 'raw',
        sldr.axisState = Gamepad('GetAxis', sldr.gamepadIndex, sldr.axe);
        disp( num2str(sldr.axisState));
    case 'log',

        sldr.axisState = Gamepad('GetAxis', sldr.gamepadIndex, sldr.axe);
        sldr.ts=GetSecs-sldr.ts0;
        sldr.count=sldr.count+1;
        sldr.value=(sldr.axisState-sldr.axisMin)/(sldr.axisMax-sldr.axisMin)*100; %0-100
        sldr.value2=(sldr.axisState-sldr.axisMid)/(sldr.axisMax-sldr.axisMin)*100*2* sldr.fudge;  % -100 - 100
        fprintf(sldr.logfp, '%f\tRAT\t%d\t%f\n', sldr.ts, sldr.count, sldr.value2 );
        ts=sldr.ts;
        status=sldr.value2;
%                 disp( num2str(sldr.value2));

        return;

    case 'plot', % plot latest slider value on screen

        % fill old pos
        if ~isempty(sldr.oldRect)
            Screen('FillOval', sldr.win,  sldr.background, sldr.oldRect );
        end
        % draw sliderlines
        Screen('DrawLine', sldr.win , sldr.lineColor, sldr.x, sldr.min, sldr.x, sldr.max ,sldr.width);

        Screen('DrawLine', sldr.win , sldr.lineColor, sldr.x-sldr.line, sldr.min, sldr.x+sldr.line, sldr.min ,sldr.width);
        Screen('DrawLine', sldr.win , sldr.lineColor, sldr.x-sldr.line, sldr.max, sldr.x+sldr.line, sldr.max ,sldr.width);
        Screen('DrawLine', sldr.win , sldr.lineColor, sldr.x-sldr.line, sldr.mid, sldr.x+sldr.line, sldr.mid ,sldr.width);

        % draw new slider pos

        sldr.pos=sldr.mid+(sldr.fudge* sldr.value2/200)*(sldr.max-sldr.min);
        rect = CenterRectOnPoint(sldr.rect, sldr.x, sldr.pos);

        Screen('FillOval', sldr.win, sldr.color, rect );
        sldr.oldRect=rect;

    case {'starttime', 'zerotime', 'setstarttime' },

        sldr.ts0=GetSecs;

    case {'stop', 'finish'},
        sldr.ts=GetSecs-sldr.ts0;

        fprintf(sldr.logfp,'%f MES Count %d\n', sldr.ts, sldr.count );
        fprintf(sldr.logfp,'%f MES Finished\n', sldr.ts );

        % close logfile
        if sldr.logfp>0
            fclose(sldr.logfp);
            sldr.logfp=0;
        end

    case 'no',
        % do nothing
    otherwise,
        disp([mfilename ': Unknown command: ''' commandstr '''' ]);
end

status=1;
