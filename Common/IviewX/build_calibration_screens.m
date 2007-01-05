function[ screens] = build_calibration_screens(configuration)

n = size(configuration.points, 2);
for i = 1:n
   p = picture;
   current_point = configuration.points(i);
   x =  current_point.x;
   y =  current_point.y;
   p = add(p, 'text', '+', 'location', [x y]);
   s(i) = stimulus;

   s(i) = set(s(i), 'data', p);
end; 

screens = s;
