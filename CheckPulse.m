function [  ] = CheckPulse( dataDir, whichPulse )
%DrawDots Draw the image bit with the dots

% Read the original images in
fprintf('Reading frames\n');
imRaw = ReadFrames( dataDir, whichPulse );

data = load( sprintf('%s/Pulse%02.0f_XYPoints2D_Left.mat', dataDir, whichPulse) );

% Number of images/frames we have for this pulse
nImages = size( imRaw, 1);
% Number of points we're tracking
nPts = size( data.xyPoints, 3 ) / 2;

xyPoints = data.xyPoints;
regions = data.regTrack;
imClip = data.imClip;

clf
nRows = 1;
nCols = nImages;
for k = 1:nImages
    subplot(nRows, nCols, k)
    ShowCloseupWithPts( imClip{k,1}, regions{k,1} );
end

savefig( sprintf('%s/Pulse%02.0f_XYPoints2D_Left.fig', dataDir, whichPulse) );

end

