%% return HOG descriptor of an image
%% Tu Bui @ University of Surrey
function des = ComputeHOG(mask, img, bin, superwinsize, winsize)
%% IN   mask: binary image specifying path for the HoG window travel along
%%      img: the image to compute HoG
%%      bin: number of orientation bin in HoG descriptor (default 9)
%%      superwinsize: grid size of a HoG window (default 3 i.e. a 3x3 grid)
%%      winsize: size of a sub-window in pixel (multi-scale) (default [5,10,15])
%% OUT  des: HoG descriptor, each row is a local descriptor
if nargin < 5
    winsize = [5,10,15];
end
if nargin < 4
    superwinsize = 3;
end
if nargin < 3
    bin = 9;
end
% compute gradient & quantisation
Ix = conv2(img,[1 0 -1],'same');
Iy = conv2(img,[1 0 -1]','same');
mag = sqrt(Ix.*Ix + Iy.*Iy)/sqrt(2);
ang = round((atan2(Iy,Ix) + pi)/(2*pi) * (bin-1)) + 1;

winsize = sort(winsize,'descend');
lhalfswsize = floor(superwinsize * winsize/2);
rhalfswsize = ceil(superwinsize * winsize/2);
Nwin = length(winsize);     %number of windows considered for each center pixel
[r, c] = find(mask);

des = zeros(length(r), superwinsize*superwinsize*bin);

count = 0;
for i = 1:length(r)
    center = [c(i), r(i)];
    lx = center(1) - lhalfswsize;
    ux = center(1) + rhalfswsize - 1;
    ly = center(2) - lhalfswsize;
    uy = center(2) + rhalfswsize - 1;
    for j = 1:Nwin
        if lx(j) > 1 && ly(j) > 1 && ux(j) < size(mask,2) && uy(j) < size(mask,1)
            count = count + 1;
            des(count,:) = GetHOG(mag(ly(j):uy(j),lx(j):ux(j)),ang(ly(j):uy(j),lx(j):ux(j)), bin, superwinsize,winsize(j));
        end
    end  
end

des(count+1:end,:) = [];
end

function out = GetHOG(imag, iang,bin, superwinsize,winsize)
out = zeros(bin, superwinsize*superwinsize);
pos = 0;
for rr = 1:superwinsize
    for cc = 1:superwinsize
        pos = pos+1;
        out(:,pos) = GetLocalHOG(imag(winsize*(rr-1)+1:winsize*rr,winsize*(cc-1)+1:winsize*cc), iang(winsize*(rr-1)+1:winsize*rr,winsize*(cc-1)+1:winsize*cc), bin);
    end
end
out = reshape(out,1,size(out,1)*size(out,2));
out = out/norm(out,2);
end

function out = GetLocalHOG(imag,iang, bin)
out = zeros(bin,1);
for i = 1: length(imag(:))
    out(iang(i)) = out(iang(i)) + imag(i);
end
end