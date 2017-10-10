function mask = CannyEdge(img, threshold, kept)
%% compute canny edge with appropriate threshold
%% IN   img         input image: grayscale
%%      threshold   Canny edge lower and upper thresholds to define week and strong edge
%%      kept        how much percent do u desire to kept as edges
%% OUT  mask        binary mask '1' is edge, '0' is background

if nargin < 3
    kept = 0.02;    %keep 2% of pixes as edge if possible
end
if nargin < 2
    threshold = [0.2 0.5];
end

for h=19:-2:1
    sigma = 0.3*(h/2-1)+0.8;
    filter = fspecial('gaussian',[h h],sigma);
    mask = imfilter(img,filter,'same','replicate');
    mask = double(edge(mask,'canny',threshold));
%     mask = double(edge(mask,'canny'));                    %auto canny
    factor = sum(sum(mask))/(size(mask,1)*size(mask,2));
    if factor > kept
        break;
    end
end
return
