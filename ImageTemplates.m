function [ imSrc ] = ImageTemplates( imOriginal, xyOrig, pad )
%ImageTemplates Summary of this function goes here
%   Detailed explanation goes here


nPts = size(xyOrig, 2);

imSrc = cell( nPts, 3 );
for k = 1:nPts
    [imSrc{k,1}, imSrc{k,2}, imSrc{k,3}] = ClipImageToPoints( imOriginal, xyOrig(:,k), pad );
    imSrc{k,1} = rgb2gray( imSrc{k,1} );
end

end

