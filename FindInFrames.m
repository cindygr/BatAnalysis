function [ retData ] = FindInFrames( strDir, strCamera, imOriginal, xyOrig, pulseStart, pulseEnd )
%FindInFrame Propagate the dots through the frames
%   strDir the directory the data is in
  %   strCamera which camera to use as a string (directory name)
  % imOriginal: The image the dots were clicked in
  % xyOrig: The clicked dots
  % pulseStart: Which pulse to start with
  % pulseEnd: Which pulse to end with 

% Frame numbers for each pulse
dataPulseFrameList = load( sprintf('%spulseframelist.mat', strDir) );

% Get frame numbers to start and stop with. 
nPulses = numel( dataPulseFrameList.frame_start );
frameStart = dataPulseFrameList.frame_start(pulseStart);
frameEnd = dataPulseFrameList.frame_end(pulseEnd);

% Backtrack to the end of the previous pulse
%   You could safely set frameBacktrack to frameStart if you want
frameBacktrack = 1;
if pulseStart > 1
    frameBacktrack = dataPulseFrameList.frame_end(pulseStart-1);
end


nPts = size(xyOrig, 2);
nFrames = uint8( frameEnd - frameBacktrack + 1 );

% Putting data in here
xyPointsAll = zeros( nFrames, 2, nPts );
% Record which frame numbers we actually got 2D data fro
frameNumbers = frameBacktrack:frameEnd;

% For drawing output
nRows = 2;
nCols = 3;
count = 1;

% For doing image template search
%  pad should be roughly the dot's width in pixels, times 2
%  padDot should be roughly the dot's width in pixels
% pad/padSearch is for aligning the entire set of dots with another set
%   padDot/padSearchDot is for aligning a single dot
%  Increase padSearch to search a bigger region (bigger is slower tho)
pad = 10;
padSearch = 15;
padDot = 6;
padSearchDot = 8;

% Actual frame numbers
fFrames = [ frameStart:frameEnd frameStart-1:-1:frameBacktrack ];

% Track the points through the frames
xyGuess = xyOrig;

% The template to use for matching all of the points at once
[imSrc, imSrcRect, imSrcPts] = ClipImageToPoints( imOriginal, xyOrig, pad );
imSrc = rgb2gray( imSrc );
% The templates to use for each dot
imTemplates = ImageTemplates( imOriginal, xyOrig, padDot );

fprintf('Frame start %0.0f end %0.0f total %0.f\n', frameStart, frameEnd, nFrames);
% Same images and draw at end
%  Image, points, error
imDraw = cell( nRows, nCols, 4 );

bUseMatchAll = true;
for f = fFrames
    fprintf(' %0.0f.. ', f);
    if f == frameStart
        xyGuess = xyOrig;
        bUseMatchAll = true;
    end
    
    imDraw{count, 1} = imread( sprintf('%s%s/1_%06.0f.jpg', strDir, strCamera, f ) );
    imFrameGrayscale = rgb2gray( imDraw{count, 1}); % Matching is in gray scale
    [xyShift, errAll] = MatchTemplate( imSrc, imSrcRect, imSrcPts, imFrameGrayscale, xyGuess, pad, padSearch );
    if bUseMatchAll
        xyGuess(1,:) = xyGuess(1,:) + xyShift(1);
        xyGuess(2,:) = xyGuess(2,:) + xyShift(2);
    end
    
    [xyAdjust, imDraw{count,3}, bOutOfBds] = MatchAllTemplates( imTemplates, imFrameGrayscale, xyGuess, padDot, padSearchDot );
    driftErr = mean( sqrt(  (xyAdjust(1,:) - xyGuess(1,:)).^2 + (xyAdjust(2,:) - xyGuess(2,:)).^2 ) );
    %xyAdjust = MatchPointsIndividual( imOriginal, xyOrig, imFrame, xyGuess );
    xyPointsAll(f, :, :) = xyAdjust;
    % Uncomment this if the points are not moving as a unit (eg, the ear)
    % May cause drift
    if driftErr > padSearchDot / 2 || bOutOfBds || errAll > 0.05
        fprintf('Adjusting match all drift %0.2f err %0.2f\n', driftErr, errAll);
        %bUseMatchAll = false;
        xyGuess = 0.5 * xyGuess + 0.5 * xyAdjust; 
        figure(3);
        clf
        if count > 1
            subplot(2,2,1);
            ShowCloseupWithPts( imDraw{count-1,1}, imDraw{count-1,2} );
            title('Guess');
            subplot(2,2,2);
            ShowCloseupWithPts( imDraw{count-1,1}, xyGuess );
            title('Adjust');
        end
        subplot(2,2,3);
        ShowCloseupWithPts( imDraw{count,1}, xyGuess );
        title('Guess');
        subplot(2,2,4);
        ShowCloseupWithPts( imDraw{count,1}, xyAdjust );
        title('Adjust');
    end
        
% You could comment this out - or try to move it outside the loop.
    imDraw{count, 2} = xyAdjust;
    imDraw{count, 4} = driftErr;
    fprintf('%0.2f %0.2f, %0.2f ', imDraw{count,3}, imDraw{count,4}, errAll);
    if mod( count, nCols ) == nCols-1
        fprintf('\n');
    end
    count = count + 1;
    if count > nRows * nCols || f == fFrames(end)
        figure(3);
        clf
        for k = 1:size(imDraw,1)
            subplot(nRows, nCols, k);
            ShowCloseupWithPts( imDraw{k,1}, imDraw{k,2} );
            title(sprintf('%0.0f,e=%0.2f,%0.2f', f-k-1, imDraw{k,3:4}) );
        end
        savefig( strcat(strDir, 'pts', num2str(f, '%06.0f')) );
        count = 1;
    end
end
fprintf('Done\n');

retData = struct('xyPoints', xyPointsAll, 'frames', frameNumbers);
end

