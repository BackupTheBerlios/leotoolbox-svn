
function[ parameters ] = present(stimulus, timeout, varargin)
%
%  Present the stimulus, without duration limits, 
%  mainly for debug purposes.
%
%  J.B.C. Marsman, 
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  11/12/2006    Created

%%%  parameters have to be passed on ? 

cost = 403.7;

if (nargin == 1)
    timeout = 3;
end;
if (nargin > 2)
    %use predefined Screen parameters
    window = varargin{1};
    wRect = varargin{2};
    parameters = varargin{3};
    log_pointer = varargin{4};
else
    %create new Screen buffer
    Screen('Preference','SkipSyncTests',1);
    screennumber = max(Screen('Screens')); 
    [window, wRect] = Screen('OpenWindow', screennumber);
    log_pointer = createlog('/tmp/','houses_versus_faces');
    try
        parameters = varargin{1};
    catch 
        parameters = -1;
    end;
end;
%% --- SETTINGS FOR KEYBOARD DEVICES ---
triggerKey = KbName('t');
quitKey = KbName('escape');

oldresponses = {'r' 'g' 'b' 'y'};
newresponses = {'1' '2' '3' '4' '6' '7' '8' '9'};

current = oldresponses;

for i = 1:length(current)
   predefined_keys{i} = KbName(current{i});
end

triggerHID = 1;
responseBoxHID = 2;
nativeKeyBoardHID = 5;
%% -------------- END SETTINGS ----

for s = 1:size(stimulus,2)
    
    data = stimulus(s).data;
    
    switch class(data)
        case 'picture'
            present(data, window, wRect, log_pointer);
        otherwise
            error('Not implemented yet.');
    end;

    start = GetSecs;
    while ((GetSecs - start) < timeout)
        
        [k s keys] = KbCheck();
        for i = 1:length(predefined_keys)
           if (keys(predefined_keys{i}))
             mlog(['got response key : ' current{i}], log_pointer);
             WaitSecs(0.3);
           end;
        end;
            
        [k s keys] = KbCheck();        
        if (keys(triggerKey))
            mlog(['got trigger pulse from scanner'], log_pointer);
            WaitSecs(0.3);
        end;
        
        [k s keys] = KbCheck();
        if (keys(quitKey))
            mlog('Experiment paused', log_pointer);
            WaitSecs(0.3);
            FlushEvents;
            continueKey = KbName('space');
            while 1
                [k s keys] = KbCheck();        
                if (keys(quitKey))
                  mlog('Experiment halted!...', log_pointer);
                  Screen('FillRect', window, 0);
                  Screen('Flip', window);
                  error('Experiment halted!');
                end
                
                if (keys(continueKey))
                    mlog('Experiment continued', log_pointer);
                    break;
                end
            end;
        end
    end
end;
  
% development phase functionality : finalize screen after 'normal' present
% call

if (nargin == 1)
    finalize('Screen');
end;
