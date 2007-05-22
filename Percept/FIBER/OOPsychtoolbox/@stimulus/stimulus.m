function s = stimulus( varargin )


s.type = '';
s.data = [];

s = class(s, 'stimulus');

if (~isempty(varargin))
  s.type = class(varargin);
  s.data = varargin;    
end

