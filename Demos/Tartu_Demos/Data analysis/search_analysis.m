commandwindow;
data=autotextread('temp.txt');

data

% 
% plot(data.ACTSTIMDUR, data.RT, 'bo')
% 
% axis square
% 
% a=axis;
% a(2)=2000;
% 
% axis(a);
% 

cutoffdelay=mean(data.DELAY);

indexplus=find(data.DELAY>cutoffdelay);
indexmin=find(data.DELAY<=cutoffdelay);

indexplus;
indexmin;


plot(data.ACTSTIMDUR(indexplus), data.RT(indexplus), 'bo')
hold on
plot(data.ACTSTIMDUR(indexmin), data.RT(indexmin), 'r+')
hold off

axis square

a=axis;
a(2)=2000;

axis(a);

xlabel('Stimulus Duration (ms)');
ylabel('Reaction Time (ms)');

legend('Delay large', 'Delay short');


