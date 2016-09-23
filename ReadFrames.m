function [ images, nPulses, frames ] = ReadFrames( strDir, strCamera, pulse )
%ReadFrames Read the frames for a pulse
%   strDir: Directory files are located in (eg 9-15bat/5/)
%   strCamera: left_1 or right_1
%   pulse which pulse

[ fStart, fEnd ] = ReadPulseStartEnd( strDir );

frameStart = fStart(pulse);
frameEnd = fEnd(pulse);
frames = frameStart:frameEnd;

images = cell( frameEnd - frameStart + 1, 1 );
for k = frameStart:frameEnd
    images{k-frameStart+1,1} = imread( sprintf('%s%s/1_%06.0f.jpg', strDir, strCamera, k ) );
end

nPulses = length(fStart);
end

