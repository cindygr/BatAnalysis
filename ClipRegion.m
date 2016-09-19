function [ imClip, region ] = ClipRegion( im )
%ClipRegion Manually clip a region for the image
%   Detailed explanation goes here

figure(1)
imshow(im)
region = ginput(2);

imClip = imcrop(im, [ region(:,1) region(:,2) ] );
end

