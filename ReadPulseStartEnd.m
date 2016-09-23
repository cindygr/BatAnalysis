function [ fStart, fEnd, nPulses ] = ReadPulseStartEnd( strDir )
%ReadPulseStartEnd Read list of start/end frames for pulses
%   Detailed explanation goes here

strFile = sprintf('%spulseframelist.mat', strDir);
dataPulseFrameList = load( strFile );

p = inputParser;
% Make up one pulse that starts at 1, ends at 15
addParameter( p, 'frame_start', 1 );
addParameter( p, 'frame_end', 15 );

% Override with real pulse data (if it exists)
parse(p, dataPulseFrameList);

fStart = dataPulseFrameList.frame_start;
fEnd = dataPulseFrameList.frame_end;
nPulses = numel( dataPulseFrameList.frame_start );
end

