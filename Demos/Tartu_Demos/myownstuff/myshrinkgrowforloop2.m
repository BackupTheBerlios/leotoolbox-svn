commandwindow;
mystr='Hello Tartu';

% for i=1:length(mystr)
%     display(char(mystr(1:i)));
% end
% 
% for i=length(mystr):-1:1
%     1:i;
%     display(char(mystr(1:i)));
% end


for i=[1:length(mystr) length(mystr):-1:1]
    display(char(mystr(1:i)));
end



% task: make string appear one letter at a time /grow/shrink