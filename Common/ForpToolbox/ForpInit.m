function forp=ForpInit(triggerChar, responseChar, quitChar)

% initialize for use of Forp
% USAGE: forp=ForpInit([triggerChar, responseChar, quitChar]);
% in case you want to set a different (or limited) set,
% you can specify this here, e.g.
% forp=ForpInit('5', {'a', 'b'}, 'S');

% history
% 01-06-07  fwc first version
% 03-06-07  fwc modifications

PsychJavaTrouble;
if exist('triggerChar', 'var') && ~isempty(triggerChar)
    forp.triggerChar=triggerChar;
else
    forp.triggerChar='t';
end


if exist('responseChar', 'var') && ~isempty(responseChar)
    forp.responseChar=responseChar;
else
    forp.responseChar={'r','g','y','b'};
end

if exist('quitChar', 'var') && ~isempty(quitChar)
    forp.quitChar=quitChar;
else
    forp.quitChar='Q';
end

% followiing is for KbCheck variant of ForpKbCheck
KbName('UnifyKeyNames'); % make sure that we can use same key names on different OS's

forp.devices=GetKeyboardIndices; % get all keyboard devices, by default we'll check them all
forp.triggerKey=KbName(forp.triggerChar);
for i=1:length(forp.responseChar)
    forp.responseKey(i)=KbName(forp.responseChar(i));
end
forp.quitKey=KbName(lower(forp.quitChar));
forp.modifierKey=KbName('LeftShift');


% forp