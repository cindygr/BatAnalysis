function [ imTh, regAll, regCulled ] = FindDots( imOrig )
%FindDots Find the dots in the image using a thresholding function
%   Detailed explanation goes here

%% Remove any features not in white areas

% Threshold image - white where there are dots
imTh = ThresholdImage( imOrig );

% SIFT feature detection - run on original image
%  Assume dots are no more than 100 pixels big - increase if needed
pixsNotTh = imTh(:) < 20;
pixsTh = imTh(:) > 100;
blend = 0.75;
imG = rgb2gray( imOrig );
imBlend =uint8( round( blend * double( imG ) + (1.0 - blend) * imTh ) );
%imBlend(pixsNotTh) = imG(pixsNotTh);
%imBlend(pixsTh) = imTh(pixsTh);
%imBlend =uint8( round( blends(k) * double( rgb2gray( imOrig ) ) + (1.0 - blends(k)) * imTh ) );
regAll = detectMSERFeatures(imBlend, 'RegionAreaRange', [1, 100], ...
                            'ThresholdDelta', 0.7, ...
                            'MaxAreaVariation', 0.4);

% Now get rid of features not in white areas
regKeep = zeros( regAll.Count,1 ) == 1;
pixOverlap = zeros( regAll.Count, 1 );
for r=1:regAll.Count
    % Number of white pixels
    pixOverlap(r) = Overlap( regAll.PixelList(r), imTh );

    % You can safely set this pretty low - but should be bigger than 0
    if pixOverlap(r) > 0.01
        regKeep(r) = true;
    end
end

% Get the regions we want - save overlap values for later
regWhite = regAll(regKeep);
pixOverlap = pixOverlap( regKeep );

% Now remove duplicates
regCulled = RemoveDuplicates( regWhite, imTh, pixOverlap );

end

