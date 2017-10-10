function out=GFinterpolate(mask,img)
%% Interpolate GF image from binary sketch or canny edge
%% IN   mask        binary image, 1 - edge, 0 - background
%%      img         destination image
%% OUT  out         gradient field image
%% Tu Bui @ University of Surrey

assert(size(mask,1)==size(img,1) && size(mask,2)==size(img,2));
%pad 15% pixel area
% pad = round(0.075*size(img));
% mask = padarray(mask,pad);
% img = padarray(img,pad);

% Build sparse maxtrix A,B
wid = size(img,2);
hei = size(img,1);
nz = wid*hei*5;                 %estimate number of nonzero in the sparse matrix
Ax = zeros(nz,1);
Ay = zeros(nz,1);
Av = zeros(nz,1);
B = zeros(wid*hei,1);
count=0;

% Build A,B from non-edge pixels of the image 
for y = 2:size(img,1)-1
    for x=2:size(img,2)-1
        if(mask(y,x))   %known pixel
            Ay(count+1,1)=wid*(y-1)+x;
            Ax(count+1,1)=wid*(y-1)+x;
            Av(count+1,1)=1;
            B(wid*(y-1)+x,1) = img(y,x);
            count = count+1;
        else            %unknown pixel
            Ay(count+1:count+5,1) = (wid*(y-1)+x)*ones(5,1);
            Ax(count+1:count+5,1) = [wid*(y-1)+x; wid*(y-1)+x-1; wid*(y-1)+x+1; wid*(y-2)+x; wid*y+x];
            Av(count+1:count+5,1) = [4;-1;-1;-1;-1];
            count = count+5;
        end
    end
end

% build edges
for x = 2:size(img,2)-1     %top and bottom edge
    Ay(count+1:count+4,1) = x*ones(4,1);
    Ax(count+1:count+4,1) = [x; x-1; x+1; wid+x];
    Av(count+1:count+4,1) = [3; -1; -1; -1];
    count = count+4;
    
    Ay(count+1:count+4,1) = (wid*(hei-1)+x)*ones(4,1);
    Ax(count+1:count+4,1) = [wid*(hei-1)+x; wid*(hei-1)+x-1;wid*(hei-1)+x+1; wid*(hei-2)+x];
    Av(count+1:count+4,1) = [3; -1; -1; -1];
    count = count+4;
end

for y = 2:size(img,1)-1     %left and right edge
    Ay(count+1:count+4,1) = (wid*(y-1)+1)*ones(4,1);
    Ax(count+1:count+4,1) = [wid*(y-1)+1; wid*(y-1)+2; wid*(y-2)+1; wid*y+1];
    Av(count+1:count+4,1) = [3; -1; -1; -1];
    count = count+4;
    
    Ay(count+1:count+4,1) = (wid*y)*ones(4,1);
    Ax(count+1:count+4,1) = [wid*y; wid*y-1; wid*(y-1); wid*(y+1)];
    Av(count+1:count+4,1) = [3; -1; -1; -1];
    count = count+4;
end

%build corners
Ay(count+1:count+3,1) = ones(3,1);
Ax(count+1:count+3,1) = [1; 2; wid+1];
Av(count+1:count+3,1) = [2; -1; -1];
count = count + 3;

Ay(count+1:count+3,1) = wid*ones(3,1);
Ax(count+1:count+3,1) = [wid; wid-1; 2*wid];
Av(count+1:count+3,1) = [2; -1; -1];
count = count + 3;

Ay(count+1:count+3,1) = (wid*(hei-1)+1)*ones(3,1);
Ax(count+1:count+3,1) = [wid*(hei-1)+1; wid*(hei-2)+1; wid*(hei-1)+2];
Av(count+1:count+3,1) = [2; -1; -1];
count = count + 3;

Ay(count+1:count+3,1) = (hei*wid)*ones(3,1);
Ax(count+1:count+3,1) = [hei*wid; wid*(hei-1); wid*hei-1];
Av(count+1:count+3,1) = [2; -1; -1];
count = count + 3;

%solve
Ax = Ax(1:count,1);
Ay = Ay(1:count,1);
Av = Av(1:count,1);
A = sparse(Ay,Ax,Av,wid*hei,wid*hei,count);
B=sparse(B);
X=A\B;
X=full(X);
out=reshape(X,size(img,2),size(img,1))';
% out = X(pad(1)+1:size(X,1)-pad(1),pad(2)+1:size(X,2)-pad(2));

