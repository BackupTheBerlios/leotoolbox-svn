function[]= simple_fixation_plot(data, t)
%%
%  J.B.C.Marsman,
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences / 
%  Experimental Ophtalmology
%  University Medical Center Groningen
% 
%  This function can be used to check the recorded sequence of fixations with 
%  the matlab log file. It results in a plot with the fixations in (x,y)
%  space plotted over time in minutes. The starting point of stimuli as
%  annotted in the matlab log are presented as transparent surfaces.
%
%  You can play with the offset, to get the starting points in agreement.
%
%  Usage: 
%    simple_fixation_plot(data [,timings])
%
%    data    : structure of read ascii file (see readIDFevents)
%    timings : array of doubles, see extract_set_timings
%
%  Revision history :
%
%  22/5/2007    Created



if nargin >= 1 

    k=1;
    for i = 1:length(data)       
        for j = 1:length(data(i).fixations)
            f = data(i).fixations(j);
            %% we're only interested in fixations within the screen
            %% dimensions
            if (f.location_x > 0 && f.location_x < 1024 && f.location_y > 0 && f.location_y < 768)
                x(k) = f.location_x;
                y(k)=  f.location_y;
                z(k)= f.start / 60000;
                k= k+1;
            end
        end
    end
    figure
    plot3(z,x,y, 'LineWidth', 1.2);
    ylabel('X');
    zlabel('Y');
    xlabel('T (minutes)');
end
   
offset = t(9);
if nargin == 2
    
    hold on;
    
    for i = 1:length(t)    
        [x y] = meshgrid(1:200:512, 1:200:768);
        z = repmat((t(i) + offset)/60, size(x,1), size(y,2));
        obj = surf(z, x,y);
        alpha(obj, 0.1);
        %plot(repmat(t(i),5)/60 ,1:5);    
    end
end