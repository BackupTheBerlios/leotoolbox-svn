function[ eight_letters old_letters] = present_lettertask(stimulus, timeout, varargin)
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
    eight_letters = varargin{5};
    old_letters =  varargin{6};
else
    %create new Screen buffer
    Screen('Preference','SkipSyncTests',1);
    screennumber = max(Screen('Screens')); 
    [window, wRect] = Screen('OpenWindow', screennumber);
    
    try
        parameters = varargin{1};
    catch 
        parameters = -1;
    end;
end;

for s = 1:size(stimulus,2)
    
    data = stimulus(s).data;

    %% loop inside stimuli, so fading in/out can happen.
    layer0 = data;
    

    
    
    if (eight_letters ~= old_letters)
        %% fade in/out
            
        while letter_alpha < 1
            letter_alpha = letter_alpha + 0.1;
            WaitSecs(0.5);
            % add random letters            
            with_letters = drawLetters(layer0, eight_letters, letter_alpha);
           % with_letters = drawLetters(layer0, old_letters, 1 - letter_alpha);
            present(with_letters, window, wRect, log_pointer);
        end        
    else
       with_letters = drawLetters(layer0, eight_letters, 1);
       present(with_letters, window, wRect, log_pointer);
       
        % show random letters, and let them fade
   t1 = evalin('base', 'start');   
   t2 = GetSecs;
   old_letters = eight_letters;
   while 1
     t3 = GetSecs;
     if (t3-t1 > 3)
         eight_letters = random_eight_letters;
     end
     
     if ((t3 - t2) > timeout)
         break;
     end
   end
   
    end;
   %% WaitSecs(timeout);
    
end;
  
% development phase functionality : finalize screen after 'normal' present
% call
if (nargin == 1)
    finalize('Screen');
end;

   
   
function[p] = drawLetters(p, letters, letter_alpha)
    r = 70; % relative radius in percentages
    number_per_picture = 8;
    points = linspace(0, 2*pi, number_per_picture+1);
    xs = r * cos(points);
    ys = r * sin(points);
    for i = 1:number_per_picture
       locations{i} = [xs(i) ys(i)];
    end; 
            
    for j = 1:8,
        
        text = letters(j);
        p = add(p, 'text', text, 'location',locations{j} , 'position', 'rel', 'alpha', letter_alpha);
        
      end          