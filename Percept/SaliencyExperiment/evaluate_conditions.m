function[b] = evaluate_conditions(parameterlist)
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created
 
timing_slots = parameterlist(1).value;
timing_slots
if size(parameterlist(1).value, 2) > 15 
     
     
     b = false;
 else
     b = true;
 end;