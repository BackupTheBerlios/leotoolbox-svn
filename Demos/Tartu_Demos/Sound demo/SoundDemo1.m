% sound demo

amp=1;
Fs=8192*4;
if 0
    % random noise
    y=rand(Fs,1)*amp;
else
    % sinus
    y=linspace(0, Fs/16, Fs);
    y=sin(y)*amp;
end

if 1
%     plot(y)
%     return
end
y=[y y y];


if IsWin
    sound(y, Fs);
else
    p = audioplayer(y, Fs);
    Fs=get(p, 'SampleRate')

    %     play(p, [1 (get(p, 'SampleRate') * 3)]);
    play(p);
end

disp('done');

