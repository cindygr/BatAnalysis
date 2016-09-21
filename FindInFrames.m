function [ retData ] = FindInFrames( strDir, strCamera, imOriginal, xyOrig, pulseStart, pulseEnd )
%FindInFrame Summary of this function goes here
%   Detailed explanation goes here

dataPulseFrameList = load( sprintf('%spulseframelist.mat', strDir) );

nPulses = numel( dataPulseFrameList.frame_start );
frameStart = dataPulseFrameList.frame_start(pulseStart);
frameEnd = dataPulseFrameList.frame_end(pulseEnd);

frameBacktrack = 1;
if pulseStart > 1
    frameBacktrack = dataPulseFrameList.frame_end(pulseStart-1);
end
nPts = size(xyOrig, 2);
nFrames = uint8( frameEnd - frameBacktrack + 1 );
xyPointsAll = zeros( nFrames, 2, nPts );
frameNumbers = frameBacktrack:frameEnd;

nRows = 5;
nCols = 7;
count = 1;
fFrames = [ frameStart:frameEnd frameStart-1:-1:frameBacktrack ];
pad = 10;
padDot = 6;
padSearch = 15;
padSearchDot = 8;

xyGuess = xyOrig;
[imSrc, imSrcRect, imSrcPts] = ClipImageToPoints( imOriginal, xyOrig, pad );
imSrc = rgb2gray( imSrc );
imTemplates = ImageTemplates( imOriginal, xyOrig, padDot );

fprintf('Frame start %0.0f end %0.0f total %0.f\n', frameStart, frameEnd, nFrames);
for f = fFrames
    fprintf(' %0.0f.. ', f);
    if f == frameStart
        xyGuess = xyOrig;
    end
    xyPointsAll(f, :, :) = xyGuess;
    imFrame = imread( sprintf('%s%s/1_%06.0f.jpg', strDir, strCamera, f ) );
    xyShift = MatchTemplate( imSrc, imSrcRect, imSrcPts, imFrame, xyGuess, pad, padSearch );
    xyGuess(1,:) = xyGuess(1,:) + xyShift(1);
    xyGuess(2,:) = xyGuess(2,:) + xyShift(2);
    
    xyAdjust = MatchAllTemplates( imTemplates, imFrame, xyGuess, padDot, padSearchDot );
    %xyAdjust = MatchPointsIndividual( imOriginal, xyOrig, imFrame, xyGuess );
    xyPointsAll(f, :, :) = xyAdjust;
    
    figure(3);
    subplot(nRows, nCols, count);
    ShowCloseupWithPts( imFrame, xyGuess );
    count = count + 1;
    if count > nRows * nCols || f == fFrames(end)
        count = 1;
        savefig( strcat(strDir, 'pts', num2str(f, '%06.0f')) );
        fprintf('\n');
    end
end
fprintf('Done\n');

retData = struct('xyPoints', xyPointsAll, 'frames', frameNumbers);
end

