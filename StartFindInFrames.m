function [ xyPointsAll ] = StartFindInFrames( strDir, pulseStart, pulseEnd, name )
%StartFindInFrames Pick dots and track them between pulses
%   strDir: Directory files are located in (eg 9-15bat/5/)
%   pulseStart: Which pulse to start with
%   pulseEnd: Which pulse to end with. Set to -1 to do all
%   name: Name to tag output files with

fprintf('Reading first frame for pulse %0.0f\n', pulseStart);
strCameras = {'left_1', 'right_1'};
[imRaw,nPulses,~] = ReadFrames( strDir, strCameras{1}, pulseStart );
if pulseEnd == -1
    pulseEnd = nPulses;
end
imInitial = imRaw{1,1};

% Get starting points - delete file if you want to re-do
strStartPts = sprintf('%s%s_TrackPts_%02.0f.mat', strDir, name, pulseStart);
fprintf('File name for clicked points %s\n', strStartPts);
if exist( strStartPts, 'file')
    ptsOrig = load( strStartPts );
    ptsOrigClick = ptsOrig.ptsOrigClick;
else
    fprintf('Getting dots in both cameras\n');
    fig = figure(1);
    clf;
    
    ptsOrigClick = cell( numel(strCameras), 1 );
    for c = 1:numel(strCameras)
        fprintf('Crop frame by dragging box\n');
        fprintf('Double click in box when done\n');
        [imClip, imClipRect] = imcrop( imInitial );

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
    end
    save( strStartPts, 'ptsOrigClick' );
end

% Clip to points
padCutout = 15;
padSearch = 40;

xyPointsAll = cell( numel(strCameras), 1);
for c = 1:numel(strCameras)
    % Line up clicked points with image
    [imFrames] = ReadFrames( strDir, strCameras{c}, pulseStart );
    imFrame = imFrames{1,1};
    ptsOrig = ptsOrigClick{c,1};

    xyShift = MatchAll( imInitial, ptsOrig, imFrame, ptsOrig, padCutout, padSearch );
    ptsInFrame = [ptsOrig(1,:) + xyShift(1); ptsOrig(2,:) + xyShift(2)];
    
    % Find Regions in the clipped out area of the start frame
    fprintf('Finding features\n');
    [imClip, imClipRec, ptsTrackMove] = ClipImageToPoints( imFrame, ptsInFrame, padCutout );
    [imT, regAll, regCull ] = FindDots( imClip );
    
    % Snap the shifted pts in the frame to the regions
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
        imshow( imFrame );
        hold on;
        plot( ptsToTrack(1,:), ptsToTrack(2,:), '+c', 'MarkerSize', 20 );
        title('Original image with points');
        
        subplot(nRows, nCols, 2)
        imshow( imFrame );
        hold on;
        plot( ptsOrig(1,:), ptsOrig(2,:), '+c', 'MarkerSize', 20)
        title('Clicked points');
        
        subplot(nRows, nCols, 3)
        imshow( imT );
        hold on;
        plot(regAll);
        title('All features');
        
        subplot(nRows, nCols, 4)
        imshow( imClip );
        hold on;
        plot(regCull);
        title('Culled features');
        
        subplot(nRows, nCols, 5)
        ShowCloseupWithPts( imFrame, ptsToTrack );
        title('Points to track');
        
        savefig( sprintf('%s%s_TrackPts_%02.0f.fig', strDir, name, pulseStart) );
    end
    
    xyPointsAll{c,1} = FindInFrames( strDir, strCameras{c}, imFrame, ptsToTrack, pulseStart, pulseEnd );
    save( sprintf('%s%s_xyPoints_%02.0f_%02.0f.mat', strDir, name, pulseStart, pulseEnd), 'xyPointsAll');;
end
end
