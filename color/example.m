%% example code to compute GFHoG descriptors from image and sketch
%% Tu Bui @ University of Surrey

% sketch
inpath = 'underground_sketch.png';
[des_shape, des_color] = ComputeGF_colour(inpath,0);

% % image
% inpath = 'sunrise_photo.jpg';
% [des_shape, des_color] = ComputeGF_colour(inpath,1);