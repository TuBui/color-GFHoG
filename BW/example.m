%% example code to compute GFHoG descriptors from image and sketch
%% Tu Bui @ University of Surrey

% sketch
inpath = 'circle.png';
des = ComputeGF(inpath,0);

% image
inpath = 'moon.jpg';
des = ComputeGF(inpath,1);