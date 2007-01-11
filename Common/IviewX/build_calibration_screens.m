function[ screens] = build_calibration_screens(configuration)

n = size(configuration.points, 2);
for i = 1:n
   p(i) = picture;
   current_point = configuration.points(i);
   x =  current_point.x;
   y =  current_point.y;
   p(i) = add(p(i), 'text', '+', 'location', [x y]);
   
end; 

screens = p;
