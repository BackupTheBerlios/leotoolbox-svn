function VideoCaptureDemo(fullscreen)
commandwindow;
AssertOpenGL;
disp(mfilename);
screenNumber=max(Screen('Screens'));
if nargin < 1
    fullscreen=0;
end;

try
    if fullscreen<1
        win=Screen('OpenWindow', screenNumber, 0, [0 0 800 600]);
    else
        win=Screen('OpenWindow', screenNumber, 0);
    end;

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen


    % Initial flip to a blank screen:
    Screen('Flip', win);

    % Set text size for info text. 24 pixels is also good for Linux.
    Screen('TextSize', win, 24);

    grabber = Screen('OpenVideoCapture', win, 0, [0 0 640 480])
    brightness = Screen('SetVideoCaptureParameter', grabber, 'Brightness',383)
    exposure = Screen('SetVideoCaptureParameter', grabber, 'Exposure',130)
    gain = Screen('SetVideoCaptureParameter', grabber, 'Gain')
    gamma = Screen('SetVideoCaptureParameter', grabber, 'Gamma')
    shutter = Screen('SetVideoCaptureParameter', grabber, 'Shutter',7)
    Screen('SetVideoCaptureParameter', grabber, 'PrintParameters')
    vendor = Screen('SetVideoCaptureParameter', grabber, 'GetVendorname')
    model  = Screen('SetVideoCaptureParameter', grabber, 'GetModelname')

    mov = avifile('myexample3.avi', 'fps', 2);

mov
    
    Screen('StartVideoCapture', grabber, 60, 1);
%     [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, 1, 0);

    oldpts = 0;
    count = 0;
    txc=1;
    t=GetSecs;
    while (GetSecs - t) < 600
        if KbCheck
            break;
        end;

        [tex pts nrdropped]=Screen('GetCapturedImage', win, grabber, 1);
        % fprintf('tex = %i  pts = %f nrdropped = %i\n', tex, pts, nrdropped);

        if (tex>0)
            % Setup mirror transformation for horizontal flipping:

%             Screen('Rect', tex(txc));

            % xc, yc is the geometric center of the text.
%             [xc, yc] = RectCenter(Screen('Rect', win));

%             % Make a backup copy of the current transformation matrix for later
%             % use/restoration of default state:
%             Screen('glPushMatrix', win);
%             % Translate origin into the geometric center of text:
%             Screen('glTranslate', win, xc, 0, 0);
%             % Apple a scaling transform which flips the direction of x-Axis,
%             % thereby mirroring the drawn text horizontally:
%             Screen('glScale', win, -1, 1, 1);
%             % We need to undo the translations...
%             Screen('glTranslate', win, -xc, 0, 0);
%             % The transformation is ready for mirrored drawing:

            % Draw new texture from framegrabber.
%             Screen('DrawTexture', win, tex, [], CenterRect(Screen('Rect', win)/2, Screen('Rect', win)));

            mov=addframe(mov, Screen('GetImage',tex));

%                     temp=Screen('GetImage',tex(i));

            
%             Screen('glPopMatrix', win);

            % Print pts:
            Screen('DrawText', win, sprintf('%d', count), 0, 0, white);
%             Screen('DrawText', win, sprintf('%.4f', pts - t), 0, 20, white);
            if count>0
                % Compute delta:
                delta = (pts - oldpts) * 1000;
                oldpts = pts;
                Screen('DrawText', win, sprintf('%.4f', delta), 0, 40, white);
            end;

            % Show it.
            Screen('Flip', win);
            Screen('Close', tex);
            tex=0;
        end;
        count = count + 1;
        if count>=50  %  frames recorded
            break;
        end
    end;



    telapsed = GetSecs - t
    avgfps = count / telapsed
    Screen('StopVideoCapture', grabber);
    Screen('CloseVideoCapture', grabber);

%     disp('now replaying recorded video');
    % replay recorded video (textures)
    Screen('FillRect', win, black);
    Screen('Flip', win);

%     WaitSecs(1);

    frames=length(tex);
    [h v]=WindowSize(tex(1));
    
%     vimat=zeros(v,h,frames);
%     
%     size(vimat);
%     

% mov = avifile('myexample.avi')


%     i=1;
%     while 1
%         if KbCheck
%             break;
%         end
% 
% %         Screen('DrawTexture', win, tex(i), [], CenterRect(Screen('Rect', win)/4, Screen('Rect', win)));
% %         Screen('DrawText', win, sprintf('%d', i), 0, 0, white);
% %         Screen('Flip', win,[],1);
% %        
%         disp(['getting image ' num2str(i)]);
%         
%         temp=Screen('GetImage',tex(i));
%         size(temp)
%         
% %         vimat(:,:,i)=squeeze(mean(temp,3));
% 
% % mov=addframe(mov, squeeze(mean(temp,3)))
% mov=addframe(mov, temp);
% 
%         i=i+1
%         if i>length(tex)
%             i=1;
%             break;
%         end
%         
%         
%         
% 
%     end

   
    disp('now closing avi video');

    mov = close(mov)
  
     disp('done');
   
    
    
    Screen('CloseAll');
catch
    disp('some error occured');

    Screen('CloseAll');
end;
