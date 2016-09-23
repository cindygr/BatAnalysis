function [ retData ] = FindInFrames( strDir, strCamera, imOriginal, xyOrig, pulseStart, pulseEnd )
%FindInFrame Propagate the dots through the frames
%   strDir the directory the data is in
  %   strCamera which camera to use as a string (directory name)
  % imOriginal: The image the dots were clicked in
  % xyOrig: The clicked dots
  % pulseStart: Which pulse to start with
  % pulseEnd: Which pulse to end with 

% Frame numbers for each pulse
[ fStart, fEnd ] = ReadPulseStartEnd( strDir );

% Get frame numbers to start and stop with. 
frameStart = fStart(pulseStart);
frameEnd = fEnd(pulseEnd);

% Backtrack to the end of the previous pulse
%   You could safely set frameBacktrack to frameStart if you want
frameBacktrack = 1;
if pulseStart > 1
    frameBacktrack = fStart(pulseStart-1);
end


nPts = size(xyOrig, 2);
nFrames = uint8( frameEnd - frameBacktrack + 1 );

% Putting data in here
xyPointsAll = zeros( nFrames, 2, nPts );
% Record which frame numbers we actually got 2D data fro
frameNumbers = frameBacktrack:frameEnd;

% For drawing output
nRows = 3;
nCols = 5;
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
xyAdjust = xyGuess;

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
countAdjust = 1;
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
    
    [xyAdjust, imDraw{count,3}, bOutOfBds] = MatchAllTemplates( imTemplates, imFrameGrayscale, ...
        xyGuess, xyAdjust, padDot, padSearchDot );
    driftErr = mean( sqrt(  (xyAdjust(1,:) - xyGuess(1,:)).^2 + (xyAdjust(2,:) - xyGuess(2,:)).^2 ) );
    
    xyPointsAll(f, :, :) = xyAdjust;
    
    % If the template for all the points is not matching very well then
    %  adjust it a bit by the latest set of points
    % May cause drift
    if (driftErr > padSearchDot / 3 || errAll > 0.04)  && ~bOutOfBds && countAdjust < 0
        fprintf('Adjusting match all drift %0.2f err %0.df, err In %0.3f\n', driftErr, errAll, imDraw{count,3});
        %bUseMatchAll = false;
        xyGuess = 0.75 * xyGuess + 0.25 * xyAdjust; 

        % Only do this every 5 frames
        countAdjust = 5;
    end
    if bOutOfBds || countAdjust == 5
        figure(2);
        clf
        countPrev = count - 1;
        if countPrev < 1
            countPrev = nRows * nCols - 1;
        end
        % Previous frame with adjust and guese
        subplot(2,2,1);
        ShowCloseupWithPts( imDraw{countPrev,1}, imDraw{countPrev,2} );
        title('Adjust');
        subplot(2,2,2);
        ShowCloseupWithPts( imDraw{countPrev,1}, xyGuess );
        title('Guess');

        % This frame with 
        subplot(2,2,3);
        ShowCloseupWithPts( imDraw{count,1}, xyGuess );
        title('Guess');
        subplot(2,2,4);
        ShowCloseupWithPts( imDraw{count,1}, xyAdjust );
        title('Adjust');
        
        savefig( strcat(strDir, 'bad_pts_', num2str(f, '%06.0f')) );
    end
    % Decrement ever round
    countAdjust = countAdjust - 1;

    % Save for drawing later
    imDraw{count, 2} = xyAdjust;
    imDraw{count, 4} = driftErr;
    
    % Error in movement of each template, drift of adjust points from
    % guess, error in movement of the big template
    fprintf('M%0.3f D%0.2f, A%0.3f ', imDraw{count,3}, imDraw{count,4}, errAll);
    if mod( count, nCols ) == nCols-1
        fprintf('\n');
    end
    
    % Draw every nRows*nCols
    count = count + 1;
    if count > nRows * nCols || f == fFrames(end)
        figure(3);
        clf
        for k = 1:size(imDraw,1)
            subplot(nRows, nCols, k);
            ShowCloseupWithPts( imDraw{k,1}, imDraw{k,2} );
            title(sprintf('%0.0f,e=%0.3f,%0.3f', f-k-1, imDraw{k,3:4}) );
        end
        savefig( strcat(strDir, 'pts', num2str(f, '%06.0f')) );
        count = 1;
    end
end
fprintf('Done\n');

retData = struct('xyPoints', xyPointsAll, 'frames', frameNumbers);
end

