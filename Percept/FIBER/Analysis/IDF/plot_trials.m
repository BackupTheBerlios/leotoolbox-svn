function[] = plot_trials( trials, type )
close all;
if type == 1
    plotHistogram(trials);
else
    plotHFSignal(trials);
end


function plotHistogram(trials)
f = figure;
subplot(2,1,1);
title('Object which has been inspected');
hold on;


overall_histogram = zeros(1, 8);

legendtext = {};

lindex = 1;

for i = 1:length(trials)
     time = trials(i).data{1};
     y = trials(i).data{8};
         
     divider_x = repmat(time(i), 1, 10);
     divider_y = [1:10];
     plot(divider_x, divider_y, 'r'); %% red vertical bar separating trials       
     plot(time, y); %% plot the object inspected
     
     legendtext{lindex} = ['Trial ' num2str(i)];
     legendtext{lindex+1} = ['Divider for Trial ' num2str(i)];
     lindex = lindex + 2;
     overall_histogram = overall_histogram + histc(y, [1:8]);
end;
legend(legendtext); %% only useful for the plot browser, so you can see where the experiment started

hold off;

subplot(2,1,2);
title('Duration of every trial');

timings_x = [1:length(trials)];
for i = 1:length(trials)
    timings_y(i) = trials(i).duration;   
end;

bar(timings_x, timings_y);

hold off;










function plotHFSignal(trials)
%% plot all house/face fixations

titles = {'Look at faces '; 'Look at houses '; 'Free viewing '};


%gc_task(1) = figure;
%hold on;
%gc_task(2) = figure;
%hold on;
%gc_task(3) = figure;
%hold on;

categories = { ''; ''; 'houses'; ''; '';  ''; 'faces'; '';  ''};


plot_index = 1;
subplot_index = 1;
title_index = 1;
hold on;
for i = 1: length(trials)    
    try
        time = trials(i).data{1};        
        hf_signal = trials(i).data{11};

        if (plot_index == 6)
            title(titles(title_index));
            plot_index = 1;
            title_index = title_index +1;
            figure; hold on;

        end;
        if (title_index ==4)
            title_index = 1;
        end;
        if (subplot_index == 5)
            subplot_index = 1;
            
        end;

        divider_x = repmat(time(i), 1, 5);
        divider_y = [-2:2];
        %figure(gc_task(plot_index));
        %subplot(2,2, subplot_index);
        
        plot( divider_x, divider_y, 'r'); %% red vertical bar separating trials       
        plot( time, hf_signal);     

        ylim([-2 2]);
        set(gca, 'YTickLabels',categories);

        
        plot_index = plot_index +1;
        subplot_index = subplot_index + 1;
        
    catch
        fprintf(['Trial ' num2str(i) ' has no stimulus information\n']);
    end;
end;



