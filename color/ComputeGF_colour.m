function [des_shape, des_color] =  ComputeGF_colour(IN, TYPE, OPTION)
%% it is the combination of CannyExtract and Canny2GF function
%% TYPE = 0 for sketch/ 1 for image
%% Tu Bui @ University of Surrey

RESIZE = 200;

if nargin < 3
    OPTION = '-e 1 -g 1';
end

if strcmp(OPTION(1:4),'-e 0')
    exportedge = 0;
else
    exportedge = 1;
end
if strcmp(OPTION(6:9),'-g 0')
    exportgfimg = 0;
else
    exportgfimg = 1;
end

% extract canny edge & compute GF
Kx=[-1 0 1; -2 0 2; -1 0 1];
Ky=[1 2 1; 0 0 0; -1 -2 -1];
cform = makecform('srgb2lab');
invcform = makecform('lab2srgb');

    try
        img = imread(IN);
    catch
        fprintf('Error while reading "%s"\n',IN);
    end
    sf=RESIZE/max(size(img));
    newsize = round(size(img)*sf);
    img=imresize(img,newsize(1:2),'bilinear');
    cimg = double(applycform(img,cform))/255;
    cL = cimg(:,:,1);
    ca = cimg(:,:,2);
    cb = cimg(:,:,3);
    if TYPE     %image
        mask = CannyEdge(cL);
    else        %sketch
        mask = double(cL < 1);
        ca = GFinterpolate(mask,ca.*mask);
        cb = GFinterpolate(mask,cb.*mask);
    end
    grad.dx = conv2(mask,Kx,'same');
    grad.dy = conv2(mask,Ky,'same');
    
    intdx = GFinterpolate(mask,grad.dx);
    intdy = GFinterpolate(mask,grad.dy);
    intimg=cos(atan2(intdy,intdx));
    intimg = (intimg+1)/2;
    [~,name,~] = fileparts(IN);
    if exportedge
        imwrite(mask,[name '_edge.png']);
    end
    
    if exportgfimg
        gfpath =  [name '_gf.png'];
        gfimg = zeros(size(intimg));
        gfimg(:,:,1) = uint8(intimg*255);
        gfimg(:,:,2) = uint8(ca*255);
        gfimg(:,:,3) = uint8(cb*255);
        gfimg = applycform(uint8(gfimg),invcform);
        imwrite(gfimg,gfpath);
    end
    
    des = ComputeHOG_colour(mask, intimg, ca, cb, 9, 3, [5 10 15], 5);
    des_shape = des(:,1:end-2);
    des_color = des(:,end-1:end);


end