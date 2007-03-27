function viewfixations

try
    clear all
    commandwindow;

    pSize=30; % radius of patches to extract (size will be 2*pSize+1
    
    KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
    keyNames.quitKey='ESCAPE';
    keyNames.nextKey='space';

    % and convert them to codes for later use
    quitKey=KbName(keyNames.quitKey);
    nextKey=KbName(keyNames.nextKey);


    fprintf(['\n\nRunning ' mfilename ' on ' datestr(now) '\n\n']);
    analysisdir='analysis';
    edffile='vy1_ng';
%     edffile='f1_dots10000';
%     edffile='f1_test10000';
%     edffile='f3_text10000';
%     %         edffile='f1';




    if 0, gettempor, end
    analysisfile=[analysisdir filesep edffile '_analysis.txt'];

    [fix,colnames]=autotextread(analysisfile)

    oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSuppressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests', 1);

    % find out about the screens attached to the computer. We take the
    % highest indexed screen as our default. We also get some default
    % colour values.
    screens=Screen('Screens');
    screenNumber=max(screens);
    [h v]=WindowSize(screenNumber);
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber);

    red=[255 0 0];
    green=[0 255 0];
    blue=[0 0 255];

    [w, wRect]=Screen('OpenWindow',screenNumber);
    Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
    Screen('FillRect',w, gray);
    Screen('FrameRect',w, red, wRect);
    Screen('Flip', w);

    gazeCoords=[0 0 1279 1023];
    wRect

    xscale=1/(gazeCoords(3)/wRect(3));
    yscale=1/(gazeCoords(4)/wRect(4));


    i=1;
    goOn=1;
    tEnd=GetSecs+300;
    while GetSecs<tEnd && goOn==1
        currentID=fix.TRIALID(i);
        imageopen=0;
        while currentID==fix.TRIALID(i)

            if imageopen==0  % open image
                fix.IMAGE{i};
                fprintf('Loading image ''%s''\n', fix.IMAGE{i});
                imdata=imread(fix.IMAGE{i});
                size(imdata);
                Screen('FillRect',w, gray);
                tex=Screen('MakeTexture', w, imdata);
                texRect=Screen('Rect', tex);
                if 1
                    orientation=fix.ORIENTATION(i);
                else
                    orientation=tempor(i);                    
                end
                Screen('DrawTexture', w, tex,[],CenterRect(smallerRect(texRect, wRect), wRect), orientation); % add orientation!
                Screen('Flip', w, 0 ,1);
                
%                 fprintf('Getting Screen image\n');
%                 scrImData=Screen('GetImage', w);
%                 size(scrImData)
                imageopen=1;
            end

            if fix.FIXNR(i)>=0
                fprintf('%.1f\t%.1f\t%d\n', fix.XPOSFIX(i), fix.YPOSFIX(i), fix.TIME2DISPON(i));
                % scale to current screen
                xfix=xscale*fix.XPOSFIX(i);
                yfix=yscale*fix.YPOSFIX(i);
                rect=CenterRectOnPoint([0 0 15 15], xfix, yfix);
                pRect=CenterRectOnPoint([0 0 pSize pSize], xfix, yfix);
                if fix.FIXNR(i)==0
                    color=green;
                elseif fix.FIXNR(i)>0
                    color=red;
                else
                    color=blue;
                end
                Screen('FillOval', w, [color 128], rect);
                Screen('FrameOval', w, [color 128], pRect);
                Screen('Flip', w, 0, 1);

                WaitSecs(fix.FDUR(i)/(3*1000));
                
%                 t=xfix-pSize;
%                 l=yfix-pSize;
%                 b=xfix+pSize;
%                 r=yfix+pSize;
%                 
%                 patchImData=scrImData()
%                 
                
            end

            i=i+1;
            if i>length(fix.TRIALID)
                break;
            end
        end

        if i>length(fix.TRIALID)
            break;
        end
        disp('Press SPACE to continue to the next trial, ESCAPE to stop');
        while 1
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyCode(quitKey)
                display('User requested break');
                goOn=0;
                break;
            end
            if keyCode(nextKey)
                Screen('FillRect',w, gray);
                Screen('Flip', w);
                break;
            end
            WaitSecs(0.01);
        end
        
        
    end
    Screen('CloseAll');
catch

    Screen('CloseAll');
    psychrethrow(psychlasterror);

end


function rect=smallerRect(rect1, rect2)

% estimate what's the bigger rect based on surface
[h1 v1]=RectSize(rect1);
[h2 v2]=RectSize(rect2);

if h1*v1<=h2*v2
    rect=rect1;
else
    rect=rect2;
end

