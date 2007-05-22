function [] = idf_plot(trial)

if length(trial) > 1
    hold on;
    for i = 1: length(trial);
        time = trial(i).data{1};
        x = trial(i).data{6};
        y = trial(i).data{7};
        plot3(time, x, y);
    end;
    hold off;
else

    time = trial.data{1};
    x = trial.data{6};
    y = trial.data{7};
    
    plot3(time, x, y);
    xlabel('Time');
    ylabel('Screen Width');
    zlabel('Screen Height');
    ylim([0 1024]);
    zlim([0 768]);
    set(gca, 'XTick', [1:100]);
    set(gca, 'YTick', [0:100:1024]);
    set(gca, 'ZTick', [0:50:768]);
    
end;
