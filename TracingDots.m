%% Automatically track dots through some number of pulses
% Uses template matching and assumes the points aren't moving all that much relative to each other
% Basic interface:
%  Pick a start and end pulse. Will do all frames inbetween
%  Outline a rectangle and select points for each camera on the start frame
%    It saves these to a TrackPts file so that you don't have to redo it all the time
%    Delete that file if you want to reselect points
%
%  Uses StartFindInFrames and FindInFrames as the main files
%
% Output:
%   Uses a "name" to tag the files so that you can do a couple different versions
%    Files are also taked with the start and end pulse
%   -TrackPt-.mat is the xy points that were picked on the image
%   -TrackPt-.fig is a figure which shows the picked points "snapped" to the features
%         Make sure that this is correct or nothing will work...
%         Some ways to fix: 
%    The upper right image is all the features it has to select from. If there isn't
%    at least one green circle over each dot then you need to make detectMSERFeatures in
%    FindDots.m be a little less picky by changing the two parameters (decrease ThresholdDelta or 
%     increase MaxAreaVariation)
%    The lower left image is both the thresholded image and the features from the
%      upper right image that overlapped them If there is no white dot where there should be
%      then you need to play with ThresholdImage to be less picky by probably decreasing
%      the number of clusters
%      If there is no green circle over each dot then you need to not cull so many dots;
%      this happens in FindDots; you can change the default for overlap 
%               if pixOverlap(r) > 0.2 
%       to be smaller
%    The bottom right image shows the selected features. They're color coded but not
%      numbered. Should have one circle over each dot.
%
%  -xyPoints-.mat is the actual points file. It is a struct with the xy points for the 
%    left and right images and the corresponding frame numbers
%      This file is read in (if it exists) and then written out so you can do the
%      cameras independently.
%
%  -pts-.fig is written out every 30 frames or so and shows the cutout images with the
%   tracked points. You should check these to see if something went wrong.

% Where the data is located
strDir = '9-15bat/5/';
pulseStart = 1;
pulseEnd = -1; % use -1 to go to the end
name = 'nose';

% Bail to the debugger if something goes boom
dbstop if error;

xyPointsAll = StartFindInFrames( strDir, pulseStart, pulseEnd, name );

% Plot the movement over time with the frames
xyLeft = xyPointsAll{1}.xyPoints;
% center
xyCenter = mean( xyLeft, 3 );
xyLeftCentered = xyLeft;
for f = 1:size(xyLeft,1)
    xyLeftCentered(f,1,:) = xyLeft(f,1,:) - xyCenter(f,1);
    xyLeftCentered(f,2,:) = xyLeft(f,2,:) - xyCenter(f,2);
end
xyMove = xyLeft(2:end,:,:) - xyLeft(1:end-1,:,:);
xyMoveMag = squeeze( sqrt( xyMove(:,1,:).^2 + xyMove(:,2,:).^2 ) );
xyMoveMagFrame = mean( xyMoveMag, 2 );

clf
plot( xyMoveMagFrame );
hold on;
% Frame numbers for each pulse
[ fStart, fEnd, nPulses ] = ReadPulseStartEnd( strDir );

for k = 1:nPulses
    plot( [fStart(k), fEnd(k)], [0.5,0.5], 'o-g' );
    plot( fEnd(k), 0.5, '+r' );
end

title('Movement');