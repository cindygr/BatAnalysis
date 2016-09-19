function [ imTh ] = ThresholdImage( im )
%ThresholdIMage Find the bat face (more or less) and threshold the image
%into bat and dot as best as possible

%% Collect pixel data and run kmeans to sort into bins
w = size(im,1);
h = size(im,2);

pixs = double( reshape( im, [w * h, 3] ) );

kClusters = 4;
[idx,c] = kmeans(pixs, kClusters);

iWhite = 1;
for k = 2:kClusters
    if sum( c(k,:) ) > sum( c(iWhite,:) )
        iWhite = k;
    end
end

imRes = zeros( w, h );
idxIm = reshape( idx, [w, h] );
for k = 1: kClusters    
    imRes( idxIm == k ) = sum( c(k,:) );
end

imG = rgb2gray( im );
imThMask = reshape(idx, [w,h]) == iWhite;
se1 = strel('disk',4);
imThMask = imdilate( imThMask, se1 );
imTh = imG;
imTh( ~imThMask ) = 0;
gMax = max(max( imTh ) );
colMin = mean( pixs( idx == iWhite, : ), 2 );
gMin = floor( min(colMin) );
imTh = round( 255 * double(imTh - gMin) / double(gMax - gMin) );

end

