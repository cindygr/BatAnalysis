function [ imCrop, regClip, ptsShiftXY ] = ClipImageToPoints( imOrig, ptsXY, pad )
%ClipImageToPoints Cut out the bit of image that surrounds the points
%   imOrig is the original image
%   ptsXY is a 2xn array of 2D points in the image
%   pad is the number of pixels to add around the points
%
%  imClip is the clipped out region
%   regClip is the crop rectangle [xmin, ymin, width, height]
%     Note that these are reveresed from what size returns

xLeft = round( min( ptsXY(1,:) ) - pad );
xRight = round( max( ptsXY(1,:) ) + pad );

yBot = round( min( ptsXY(2,:) ) - pad );
yTop = round( max( ptsXY(2,:) ) + pad );

xLeft = max( xLeft, 1 );
yBot = max( yBot, 1 );
xRight = min( xRight, size( imOrig, 2 ) );
yTop = min( yTop, size( imOrig, 1 ) );

regClip = [xLeft, yBot, xRight - xLeft, yTop - yBot];

% Convert to gray scale, just take area around points
imCrop = imcrop( imOrig, regClip );

ptsShiftXY = [ ptsXY(1,:) - regClip(1); ptsXY(2,:) - regClip(2) ];
end

