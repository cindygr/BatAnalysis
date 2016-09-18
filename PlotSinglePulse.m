function [  ] = PlotSinglePulse( whichPulse, nMic, dataPulse, dataWidth, peak, peaktime, colors )
%PlotSinglePulse Draw one pulse
%   Detailed explanation goes here

% size of data
nSamples = size( dataPulse, 3);

% X axes variables
ti = linspace(0,dataWidth(whichPulse), nSamples);

for m = 1:nMic
    plot( ti, squeeze(dataPulse(whichPulse,m,:)), 'Color', colors(:,m)', 'LineWidth', 2.0 );
    hold on;
    
    % Label location of peak
    plot( peaktime(whichPulse,m), peak(whichPulse,m), 'X', 'Color', colors(:,m)' );
    text( peaktime(whichPulse,m), peak(whichPulse,m), sprintf('%0.0f',m), 'FontSize', 20, 'Color', colors(:,m)' );
end
% Label the curves; put text on top
for m = 1:nMic
    text( peaktime(whichPulse,m), peak(whichPulse,m), sprintf('%0.0f',m), 'FontSize', 20, 'Color', colors(:,m)' );
end

xlabel('Time (ms)');
ylabel('Intensity');
title('Original pulse data');


end

