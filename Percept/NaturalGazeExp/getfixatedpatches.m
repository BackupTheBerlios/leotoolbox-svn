function getfixatedpatches

% try
clear all
commandwindow;

pSize=30; % radius of patches to extract (size will be 2*pSize+1

KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's
keyNames.quitKey='ESCAPE';
keyNames.nextKey='space';

% and convert them to codes for later use
quitKey=KbName(keyNames.quitKey);
nextKey=KbName(keyNames.nextKey);

gazeCoords=[0 0 1279 1023];
gazeRect=[0 0 1280 1024];

gazeCoords=[0 0 1023 767];
gazeRect=[0 0 1024 768];


fprintf(['\n\nRunning ' mfilename ' on ' datestr(now) '\n\n']);
analysisdir='analysis';
fixpatchesdir='fixpatches';

edffile={'vy1_ng', 'vy2_ng', 'data1_ng', 'jb1_ng', 'eg1_ng'};
reso=[1 1 1 2 2];

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




for k=1:length(edffile)

    switch reso(k)
        case 1,
    gazeCoords=[0 0 1279 1023];
gazeRect=[0 0 1280 1024];
        case 2,
gazeCoords=[0 0 1023 767];
gazeRect=[0 0 1024 768];
    end
[ow,owRect]=Screen('OpenOffscreenWindow', w, gray ,gazeRect);

    xscale=1/(gazeCoords(3)/wRect(3));
yscale=1/(gazeCoords(4)/wRect(4));

oxscale=1/(gazeCoords(3)/owRect(3));
oyscale=1/(gazeCoords(4)/owRect(4));


    analysisfile=[analysisdir filesep edffile{k} '_analysis.txt']

    [fix,colnames]=autotextread(analysisfile);

    makedir(fixpatchesdir);
    fixpatchdir=[fixpatchesdir filesep edffile{k}];
    makedir(fixpatchdir);
    meanfixpatchdir=[fixpatchesdir filesep edffile{k} filesep 'mean'];
    makedir(meanfixpatchdir);



    i=1;
    goOn=1;
    meanPatchAll=zeros(2*pSize+1,2*pSize+1,3 );
    meanPatchEarly=zeros(2*pSize+1,2*pSize+1,3 );
    pam=0;
    pae=0;

    tEnd=GetSecs+300;
    while GetSecs<tEnd && goOn==1
        currentID=fix.TRIALID(i);
        trialfixpatchdir=[fixpatchesdir filesep edffile{k} filesep 'trial_' num2str(currentID)]
        makedir(trialfixpatchdir);

        imageopen=0;
        pa=0;
        meanPatch=[];
        meanPatch=zeros(2*pSize+1,2*pSize+1,3 );
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

                % draw into the offscreen window, that is made equal to the
                % original recording window
                tempRect=smallerRect(texRect, gazeRect);
                tempRect=ScaleRect(tempRect, xscale, yscale );
                tempRect=CenterRect(tempRect, wRect);
                %                 Screen('DrawTexture', ow, tex,texRect,CenterRect(smallerRect(texRect, owRect), owRect), orientation); % add orientation!
                Screen('DrawTexture', w, tex, texRect,tempRect, orientation); % add orientation!

                % copy to the display window
                %                 Screen('CopyWindow', ow, w); %, owRect, wRect);

                % Screen('DrawTexture', w, ow); %, owRect, wRect);

                %                 Screen('DrawTexture', w, tex,[],CenterRect(smallerRect(texRect, wRect), wRect), orientation); % add orientation!
                Screen('Flip', w, 0 ,1);

                fprintf('Getting Screen image\n');

                % get screen image from the offscreen window
                scrImData=Screen('GetImage', w);
                %                 Screen('PutImage', w, scrImData, wRect);
                %                 Screen('Flip', w, 0 ,1);
                size(scrImData)
                imageopen=1;
            end

            %             if fix.FIXNR(i)>=0 && fix.FIXNR(i)<=5
            if fix.FIXNR(i)>=0
                fprintf('%.1f\t%.1f\t%d\n', fix.XPOSFIX(i), fix.YPOSFIX(i), fix.TIME2DISPON(i));
                % scale to current screen
                xfix=xscale*fix.XPOSFIX(i);
                yfix=yscale*fix.YPOSFIX(i);
                rect=CenterRectOnPoint([0 0 15 15], xfix, yfix);
                pRect=CenterRectOnPoint([0 0 2*pSize+1 2*pSize+1], xfix, yfix);
                if fix.FIXNR(i)==0
                    color=green;
                elseif fix.FIXNR(i)>0
                    color=red;
                else
                    color=blue;
                end
                Screen('FillOval', w, [color 128], rect);
                %                 Screen('FillOval', ow, [color 128], rect);
                % %                 Screen('FrameOval', w, [color 128], pRect);
                Screen('FrameRect', w, [color 128], pRect);
                %                 Screen('FrameRect', ow, [color 128], pRect);
                Screen('Flip', w, 0, 1);

                %                 WaitSecs(fix.FDUR(i)/(3*1000));

                l=round(xfix-pSize);
                t=round(yfix-pSize);
                r=round(xfix+pSize);
                b=round(yfix+pSize);
                [vv hh zz]=size(scrImData);
                vv=vv-1;
                hh=hh-1;

                if t<0, t=0; end
                if l<0, l=0; end
                if r>hh, r=hh; end
                if b>vv, b=vv; end

                if b<0, b=0; end
                if r<0, r=0; end
                if l>hh, l=hh; end
                if t>vv, t=vv; end

                % shift with 1 to go from screen coordinates to matrix
                % index
                l=l+1;
                r=r+1;
                t=t+1;
                b=b+1;
                patchImData=[];
                patchImData=scrImData(t:b,l:r,:);

                fixImName=[trialfixpatchdir filesep edffile{k} '_t' num2str(currentID) '_f' num2str(fix.FIXNR(i)) '.jpg'  ];
                %                 fixImName
                if ~isempty(patchImData)
                    imwrite(patchImData, fixImName, 'JPG', 'Quality', 100);
                end
                if fix.FIXNR(i)>0
                    if size(patchImData)==size(meanPatch)
                        pa=pa+1;
                        pam=pam+1;
                        patchImData=double(patchImData);
                        %                         for k=1:3
                        %                             patchImData(:,:,k)=patchImData(:,:,k)-mean(mean(patchImData(:,:,k)))+128;
                        %                         end
                        meanPatch=meanPatch+patchImData;
                        meanPatchAll=meanPatchAll+patchImData;
                        %seperate calc for early fixations
                        if fix.TIME2DISPON(i)<500
                            pae=pae+1;
                            meanPatchEarly=meanPatchEarly+patchImData;
                        end

                    end
                end
            end

            i=i+1;
            if i>length(fix.TRIALID)
                break;
            end
        end

        if i>length(fix.TRIALID)
            break;
        end

        meanPatch=uint8(round(meanPatch./pa));

        fixImName=[meanfixpatchdir filesep edffile{k} '_t' num2str(currentID) '_mean' '.jpg'  ];
        %         fixImName=['fixpatches' filesep edffile{k} '_t' num2str(currentID) '_mean' '.tif'  ];
        %         fixImName
        imwrite(meanPatch, fixImName, 'jpg', 'Quality', 100);
        %         imwrite(meanPatch, fixImName, 'tiff');
        %         size(meanPatch)
        %         Screen('PutImage', w, meanPatch, [], CenterRect([0 0 2*pSize+1 2*pSize+1], wRect));
        %         Screen('Flip', w, 0, 1);

        %   if 0
        %         meanPatch2=Screen('GetImage', w, CenterRect([0 0 2*pSize+1 2*pSize+1], wRect));
        %
        %        fixImName=['fixpatches' filesep edffile{k} '_t' num2str(currentID) '_mean2' '.tif'  ];
        %        size(meanPatch2)
        %        imwrite(meanPatch, fixImName, 'tiff');
        % whos
        % end

        disp('Press SPACE to continue to the next trial, ESCAPE to stop');
        tEndKeyBCheck=GetSecs+0.15;
        while GetSecs<tEndKeyBCheck
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


    meanPatchAll=uint8(round(meanPatchAll./pam));

    fixImName=[fixpatchesdir filesep edffile{k} '_mean_all' '.jpg'  ];
    fixImName
    imwrite(meanPatchAll, fixImName, 'jpg', 'Quality', 100);

    meanPatchEarly=uint8(round(meanPatchEarly./pae));

    fixImName=[fixpatchesdir filesep edffile{k} '_mean_early' '.jpg'  ];
    fixImName
    imwrite(meanPatchEarly, fixImName, 'jpg', 'Quality', 100);

    Screen('Close', ow);
end

Screen('CloseAll');
% catch
%
%     Screen('CloseAll');
%     psychrethrow(psychlasterror);
%
% end


function rect=smallerRect(rect1, rect2)

% estimate what's the bigger rect based on surface
[h1 v1]=RectSize(rect1);
[h2 v2]=RectSize(rect2);

if h1*v1<=h2*v2
    rect=rect1;
else
    rect=rect2;
end


