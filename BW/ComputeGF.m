function des = ComputeGF(IN, TYPE, OPTION)
%% IN			input image/sketch file
%% TYPE  	0 for sketch/ 1 for image
%% OPTION 	print out gradient field or edge map (for debug purpose)
%%				 format: -e [0/1] -g [0/1]
%% Tu Bui @ University of Surrey

RESIZE = 200;

if nargin < 4
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
se = ones(3);

    try
        img = imread(IN);
    catch
        fprintf('Error while reading "%s"\n',IN);
    end
    if length(size(img)) == 3
        img = double(rgb2gray(img))./255;
    else
        img = double(img)./255;
    end
    
    sf=RESIZE/max(size(img));
%     img=imresize(img,round(size(img)*sf),'bilinear');
    if TYPE
        img=imresize(img,round(size(img)*sf),'bilinear');
        mask = CannyEdge(img);
    else
        img = sketchresize(img,sf);
        mask = double(img < 1);
    end
  
    pad = round(0.05*size(mask));  %pad 20% pixel area
    mask = padarray(mask,pad);
    
    mask_temp = imdilate(mask,se);
    
    grad.dx = conv2(mask_temp,Kx,'same');
    grad.dy = conv2(mask_temp,Ky,'same');    
     
    intdx = GFinterpolate(mask_temp,grad.dx);
    intdy = GFinterpolate(mask_temp,grad.dy);
    intimg=cos(atan2(intdy,intdx));
    intimg = (intimg+1)/2;
    [~,name,~] = fileparts(IN);
    if exportedge
        imwrite(mask(pad(1)+1:size(mask,1)-pad(1),pad(2)+1:size(mask,2)-pad(2)),[name '_edge.png']);
    end
    
    if exportgfimg
        imwrite(intimg(pad(1)+1:size(intimg,1)-pad(1),pad(2)+1:size(intimg,2)-pad(2)),[name '_gf.png']);
    end
    
    des = ComputeHOG(mask, intimg, 9, 3, [5 10 15]);

end

function out = sketchresize(img,sf)
    out = ones(round(sf*size(img)));
    [r,c] = find(img==0);
    for i=1:length(r)
        out(round(r(i)*sf),round(c(i)*sf)) = 0;
    end
end