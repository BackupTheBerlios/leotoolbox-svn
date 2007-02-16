try
    windowPtr =  Screen('OpenWindow',0);
GT = Screen('ReadNormalizedGammaTable', windowPtr);
Screen('closeall');

names = {'Red','Green','Blue'};
for i=1:3
    subplot(3,1,i);
    plot(GT(:,i),'LineWidth',4); 
    title(names{i}); 
    xlabel('DAC'); 
    ylabel('Gun output');
end

catch
    disp('sorry, error');
Screen('closeall');
end