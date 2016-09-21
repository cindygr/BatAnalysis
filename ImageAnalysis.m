%% See about automatically fitting the dots on the bat's face
% Version 1: Tries to track dots through images
%  Uses TrackPoints as the main file
%  I gave up on this approa

% Where the data is located
dataDir = '9-15bat/5/';
whichPulse = 1;

if ~exist('imRaw', 'var')
    fprintf('Reading frames\n');
    [imRaw, nPulses] = ReadFrames( dataDir, whichPulse );
end

nImages = size( imRaw, 1);
fprintf('Found %0.0f frames\n', nImages);

if ~exist('imClip', 'var')
    fprintf('Cropping to dots - select a region for the first and last frames\n');
    imClip = cell( nImages,2);
    figure(1);
    clf;
    fprintf('First frame\n');
    [imClip{1,1}, imClip{1,2}] = imcrop( imRaw{1,1} );
    for k = 2:nImages
        imClip{k,2} = imClip{1,2};
        [imClip{k,1}] = imcrop( imRaw{k,1}, imClip{k,2} );
    end    
    % Alternative - do first and last and interpolate
%     fprintf('Last frame\n');
%     [imClip{end,1}, imClip{end,2}] = imcrop( imRaw{end,1} );
%     for k = 2:nImages-1
%         t = (k-1) / nImages; 
%         imClip{k,2} = round( (1-t) * imClip{1,2} + t * imClip{end,2} );
%         [imClip{k,1}] = imcrop( imRaw{k,1}, imClip{k,2} );
%     end    
    dlmwrite( strcat(dataDir, 'CropRegion.csv'), imClip{1,2} );
end


if ~exist('ptsTrack', 'var')
    fprintf('Select the points to track by clicking on them\n');
    fprintf('Double or shift click when done\n');
    fig = figure(1);
    clf
    imshow( imClip{1,1} );
    [x,y] = getpts( fig );
    ptsTrack = [ x(1:end-1)'; y(1:end-1)' ]; 
    nPts = size( ptsTrack, 2 );
    
    % Location on original image
    ptsOrig = ptsTrack;
    ptsOrig(1,:) = ptsOrig(1,:) + imClip{1,2}(1);
    ptsOrig(2,:) = ptsOrig(2,:) + imClip{1,2}(2);
    dlmwrite( strcat(dataDir, 'TrackPts.csv'), ptsOrig );
end


xyPointsAll = cell( nPulses, 1);
for p = 1:nPulses
    xyPoints = TrackPoints( dataDir, p, imRaw{1,1}, ptsOrig );
    xyPointsAll{p,1} = xyPoints;
end

save( strcat(dataDir, 'xyPointsAll.mat'), 'xyPointsAll' );

