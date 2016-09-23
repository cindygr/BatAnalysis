function [ xyPointsAll ] = StartFindInFrames( strDir, pulseStart, pulseEnd, name )
%StartFindInFrames Pick dots and track them between pulses
%   strDir: Directory files are located in (eg 9-15bat/5/)
%   pulseStart: Which pulse to start with
%   pulseEnd: Which pulse to end with. Set to -1 to do all
%   name: Name to tag output files with

fprintf('Reading first frame for pulse %0.0f\n', pulseStart);
strCameras = {'left_1', 'right_1'};
nCameras = numel(strCameras);

% Read in the image for the first frame of the pulse
%  this is the image to click the dots on
imInitialClick = cell( nCameras, 1 );
for c = 1:nCameras
    [imRaw,nPulses,~] = ReadFrames( strDir, strCameras{c}, pulseStart );
    imInitialClick{c,1} = imRaw{1,1};
end

% Do all 
if pulseEnd == -1
    pulseEnd = nPulses;
end

% Get starting points - delete file if you want to re-do
%  File name:
strStartPts = sprintf('%s%s_TrackPts_%02.0f.mat', strDir, name, pulseStart);
fprintf('File name for clicked points %s\n', strStartPts);

% Read it in if it exists
if exist( strStartPts, 'file')
    ptsOrig = load( strStartPts );
    ptsOrigClick = ptsOrig.ptsOrigClick;
else
    fprintf('Getting dots in both cameras\n');
    fig = figure(1);
    clf;

    % Get dots for each camera. 
    % Make sure to click the dots in the same order
    ptsOrigClick = cell( nCameras, 1 );
    for c = 1:nCameras
        fprintf('Crop frame by dragging box\n');
        fprintf('Double click in box when done\n');
        [imClip, imClipRect] = imcrop( imInitialClick{c,1} );

        fprintf('Select the points to track by clicking on them\n');
        fprintf('Double or shift click when done\n');
        imshow( imClip );
        [x,y] = getpts( fig );
        ptsTrack = [ x(1:end-1)'; y(1:end-1)' ];

        % Location on original image
        ptsClick = ptsTrack;
        ptsClick(1,:) = ptsClick(1,:) + imClipRect(1);
        ptsClick(2,:) = ptsClick(2,:) + imClipRect(2);
        ptsOrigClick{c,1} = ptsClick;
        
        fprintf('Clicked %0.0f points\n', size(ptsClick(2) ));
    end
    save( strStartPts, 'ptsOrigClick' );
end

% How much to pad the image when doing a template search
%   and how much of the image to search
padCutout = 15;
padSearch = 40;

% Read in the data file if it exists 
%    That way, you can re-do some of the frames without re-doing everything
strDataOut = sprintf('%s%s_xyPoints_%02.0f_%02.0f.mat', strDir, name, pulseStart, pulseEnd);
if exist( strDataOut, 'file' );
    data = load( strDataOut );
    xyPointsAll = data.xyPointsAll;
else    
    xyPointsAll = cell( nCameras, 1);
end

% Lef then right camera
for c = 1:nCameras
    % Which image and points to start with
    imInitial = imInitialClick{c,1};
    ptsOrig = ptsOrigClick{c,1};
    
    % Line up clicked points with image
    [imFrames] = ReadFrames( strDir, strCameras{c}, pulseStart );
    imFrame = imFrames{1,1};

    % This *should* return [0,0] - it's here because you probably
    % can use the clicked points from a different image as a starting point
    xyShift = MatchAll( imInitial, ptsOrig, imFrame, ptsOrig, padCutout, padSearch );
    ptsInFrame = [ptsOrig(1,:) + xyShift(1); ptsOrig(2,:) + xyShift(2)];
    
    % Find Regions in the clipped out area of the start frame
    fprintf('Finding features\n');
    [imClip, imClipRec, ptsTrackMove] = ClipImageToPoints( imFrame, ptsInFrame, padCutout );
    [imT, regAll, regCull ] = FindDots( imClip );
    
    % Snap the shifted pts in the frame to the regions
    %   This makes sure the points are in the center of the dots
    fprintf('Matching regions in first frame\n');
    [ptsIndex, ~] = MatchPoints( imFrame, ptsTrackMove, imFrame, regCull );
    regMatched = regCull( ptsIndex );
    ptsToTrack = [ regMatched.Location(:,1)' + imClipRec(1); regMatched.Location(:,2)' + imClipRec(2) ];
    
    bShow = true;
    if bShow
        fprintf('Showing results\n');
        figure(1);
        clf
        nRows = 2;
        nCols = 3;
        subplot(nRows, nCols, 1)
        imshow( imInitial );
        hold on;
        plot( ptsToTrack(1,:), ptsToTrack(2,:), '+c', 'MarkerSize', 20 );
        title('Original image with clicked points');
        
        subplot(nRows, nCols, 2)
        imshow( imFrame );
        hold on;
        plot( ptsOrig(1,:), ptsOrig(2,:), '+c', 'MarkerSize', 20)
        title('New frame with points');
        
        subplot(nRows, nCols, 3)
        imshow( imT );
        hold on;
        plot(regAll);
        title('All features');
        
        subplot(nRows, nCols, 4)
        imshow( imT );
        hold on;
        plot(regCull);
        title('Culled features');
        
        subplot(nRows, nCols, 5)
        imshow( imClip );
        hold on;
        plot(regAll);
        plot( ptsToTrack(1,:) - imClipRec(1), ptsToTrack(2,:) - imClipRec(2), '+r');
        title('All features with points');
        
        subplot(nRows, nCols, 6)
        ShowCloseupWithPts( imFrame, ptsToTrack );
        title('Points to track');
        
        savefig( sprintf('%s%s_%0.0f_TrackPts_%02.0f.fig', strDir, name, c, pulseStart) );
    end
    
    % Now propagate through the frames
    xyPointsAll{c,1} = FindInFrames( strDir, strCameras{c}, imFrame, ptsToTrack, pulseStart, pulseEnd );

    % Save here again to be on the safe side.
    save( strDataOut, 'xyPointsAll');
end
end
