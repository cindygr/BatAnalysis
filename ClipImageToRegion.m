function [ imClip, cropRect, ptsShift ] = ClipImageToRegion( imOriginal, regsPts, pad )
%ClipImageToPoints Cut out the bit of image that surrounds the points in
%the region
%   imOrig is the original image
%   ptsXY is the regions returned by detectMSERRegion
%   pad is the number of pixels to add around the points
%
%  imClip is the clipped out region
%   cropRect is the crop rectangle [xmin, ymin, width, height]

ptsXY = [ regsPts.Location(:,1)'; regsPts.Location(:,2)'];
[imClip, cropRect, ptsShift] = ClipImageToPoints( imOriginal, ptsXY, pad );

end

