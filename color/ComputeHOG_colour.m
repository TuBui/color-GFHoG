%% return HOG descriptor of a colour image
%% Tu Bui @ University of Surrey
function des = ComputeHOG_colour(mask, cL, ca, cb, bin, superwinsize, winsize, scale)
if nargin < 8
    scale = 1;
end
if nargin < 7
    winsize = [5,10,15];
end
if nargin < 6
    superwinsize = 3;
end
if nargin < 5
    bin = 9;
end
% compute gradient & quantisation
Ix = conv2(cL,[1 0 -1],'same');
Iy = conv2(cL,[1 0 -1]','same');
cLmag = sqrt(Ix.*Ix + Iy.*Iy)/sqrt(2);
cLang = round((atan2(Iy,Ix) + pi)/(2*pi) * (bin-1)) + 1;

winsize = sort(winsize,'descend');
lhalfswsize = floor(superwinsize * winsize/2);
rhalfswsize = ceil(superwinsize * winsize/2);
Nwin = length(winsize);     %number of windows considered for each center pixel
[r, c] = find(mask);

des = zeros(length(r), superwinsize*superwinsize*bin+3);

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
            des(count,1:end-3) = GetHOG(cLmag(ly(j):uy(j),lx(j):ux(j)),cLang(ly(j):uy(j),lx(j):ux(j)), bin, superwinsize,winsize(j));
            des(count,end-2) = sum(sum(cL(ly(j):uy(j),lx(j):ux(j))))/((superwinsize*winsize(j))^2) * scale;
            des(count,end-1) = sum(sum(ca(ly(j):uy(j),lx(j):ux(j))))/((superwinsize*winsize(j))^2) * scale;
            des(count,end) = sum(sum(cb(ly(j):uy(j),lx(j):ux(j))))/((superwinsize*winsize(j))^2) * scale;
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