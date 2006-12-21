function s = bitmap()
%
%  contains data on one single image
%  named 'picture' due to naming conflict with Matlab
%
s.filename = '';
s.name = '';
s.path = '';
s.data = [];
s.parameters = [];
s.category = '';

s = class(s, 'bitmap');
