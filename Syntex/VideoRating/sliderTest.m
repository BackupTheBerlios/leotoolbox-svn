function sliderTest

commandwindow;
disp(['start ' mfilename ]);

screens=Screen('Screens');
screenNumber=max(screens);
[h v]=WindowSize(screenNumber);

white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=GrayIndex(screenNumber);

[window, winrect]=Screen('OpenWindow',screenNumber);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % enable alpha blending
Screen('FillRect',window, gray);
Screen('Flip', window);



Slider('LogFileDir', 'slidertestdir');
Slider('LogFileName', 'slidertest');
Slider('Init', window);
Slider('Message', 'testtestest');
Slider('Message', ['Starttijd ' num2str(GetSecs)]);


while 1


    WaitSecs(.1);
    [x y mbs]=GetMouse;
    if ~any(mbs)
        break;
    end
end



Slider('SetStartTime');

while 1

%     Slider('Raw');
    Slider('Log');

    Slider('Plot');

    Screen('Flip', window);

    [x y mbs]=GetMouse;
    if any(mbs)
        disp('Break on mouse');
        break;
    end
    WaitSecs(0.01);

end


Slider('Stop');


Screen('CloseAll');