commandwindow;
for i=1:10
    mystr='It is all Estonian to me';
    L=length(mystr);
    L=randperm(L);
    mystr2=mystr(L);
%     mystr2=mystr(randperm(length(mystr)));
    display(char(mystr2));
end




% task: do a different kind of manipulation on string