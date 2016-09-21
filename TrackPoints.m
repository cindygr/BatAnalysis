function [ xyPoints ] = TrackPoints( dataDir, whichPulse, imInitial, ptsOrig )
%TrackPoints Track points across a single pulse
%   dataDir: Where to look for the files
%   whichPulse: 1..n
%   imInitial: The first image the points were marked on
%   ptsOrig; The points in the first image

% Read the original images in
fprintf('Reading frames\n');
imRaw = ReadFrames( dataDir, whichPulse );

% Number of images/frames we have for this pulse
nImages = size( imRaw, 1);
% Number of points we're tracking
nPts = size( ptsOrig, 2 );
% Padding of image cutout - should be sufficient to include dots and
% movement
padCutout = 100;

fprintf('Found %0.0f frames\n', nImages);

% Get an initial cutout around the original points in all images
imClip = cell( nImages,3);
for k = 1:nImages
    [imClip{k,1}, imClip{k,2}, imClip{k,3}] = ClipImageToPoints( imRaw{k,1}, ptsOrig, padCutout );
end

% Get dots out
fprintf('Thresholding images to find dots\n');
% Thresholded image, all features found, and culled features
imT = cell( nImages,3);
for k = 1:nImages
    fprintf(' %0.0f...', k);
    [imT{k,1}, imT{k,2}, imT{k,3} ] = FindDots( imClip{k,1} );
end
fprintf('\n');

% Now match points to dots
regTrack = cell(nImages, 1);

% Cutout of original image - use for frame 1
% Shift entire image clip containing points to new image
fprintf('Matching first frame\n');
[imClipInitial, imClipRect, ptsTrackMove] = ClipImageToPoints( imInitial, ptsOrig, padCutout );
[ regTrack{1,1}, ptsTrackMoveOrig ] = MatchAndMove( imClipInitial, ptsTrackMove, imClip{1,1}, imT{1,3} );
ptsTrackMove = [ regTrack{1,1}.Location(:,1)'; regTrack{1,1}.Location(:,2)' ];

for k = 2:nImages
    fprintf(' %0.0f...', k);
    [ regTrack{k,1}, ptsTrackMove ] = MatchAndMove( imClip{k-1,1}, ptsTrackMove, imClip{k,1}, imT{k,3} );
    
    figure(3);
    clf;
    imshow( imClip{k,1} );
    hold on;
    plot( imT{k,3} );
    vecs = [ regTrack{k,1}.Location(:,1)' - ptsTrackMove(1,:); ...
        regTrack{k,1}.Location(:,2)' - ptsTrackMove(2,:) ];
    quiver( ptsTrackMove(1,:), ptsTrackMove(2,:), vecs(1,:), vecs(2,:), 'or', 'MarkerSize', 20 );
    
    % Update the points to the centers of the new regions - uncomment
    % if you want to adjust the points to the local image
    %ptsTrackMove = [regTrack{k,1}.Location(:,1)'; regTrack{k,1}.Location(:,2)'];
end
fprintf('\n');

% Point locations in original image
xyPoints = zeros( nImages, 2, nPts );
for k = 1:nImages
    xyPoints(k, 1,:) = regTrack{k,1}.Location(:,1)' + imClip{k,2}(1);
    xyPoints(k, 2,:) = regTrack{k,1}.Location(:,2)' + imClip{k,2}(2);
end

fprintf('Writing out data\n');
save( sprintf('%s/Pulse%02.0f_XYPoints2D_Left.mat', dataDir, whichPulse), 'xyPoints', 'imClip', 'regTrack' );

bShow = true;
if bShow
    fprintf('Showing results\n');
    figure(1);
    clf
    nRows = 3;
    nCols = nImages;
    for k = 1:nImages
        subplot(nRows, nCols, k)
        imshow( imRaw{k,1} );
        hold on;
        plot( squeeze( xyPoints(k, 1,:) ), squeeze( xyPoints(k, 2,:) ), '+c', 'MarkerSize', 20 );
        
        subplot(nRows, nCols, nCols + k)
        imshow( imClip{k,1} );
        
        subplot(nRows, nCols, 2*nCols + k)
        imshow( imClip{k,1} );
        hold on;
        plot(imT{k,2});
    end
    figure(4);
    CheckPulse( dataDir, whichPulse );
end
end
