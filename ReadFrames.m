function [ images ] = ReadFrames( strDir, pulse )
%ReadFrames Read the frames for a pulse
%   Detailed explanation goes here

dataPulseFrameList = load( sprintf('%s/pulseframelist.mat', strDir) );

frameStart = dataPulseFrameList.frame_start(pulse);
frameEnd = dataPulseFrameList.frame_end(pulse);

images = cell( frameEnd - frameStart + 1, 1 );
for k = frameStart:frameEnd
    images{k-frameStart+1,1} = imread( sprintf('%s/left_1/%0.0f_%06.0f.jpg', strDir, pulse, k ) );
end
end

