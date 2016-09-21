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
nRows = 5;
nCols = 7;
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
    
% You could comment this out - or try to move it outside the loop.
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

