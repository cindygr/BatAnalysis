function [] = PlotPulse( whichPulse, nMic, dataPulse, dataWidth, clipPerc, g, resid, peak, peaktime )
%PlotPulse Plot the original and fitted data, and the residual error for
% each microphone, plus the peak intensity and time for each one
% dataPulse is a matrix, each row a microphone, each column the signal
% intensity
% dataWidth is the with of the pulse in milli seconds.
% clipPerc is used to clip off the right hand side of the signal
% g is the Gaussian model
% resid is the error in the fit
% peak is maximum intensity
% peaktime is the location of the maximum intensity

nRows = 3;
nCols = 8;
if nMic > 8
    nRows = 4;
end

% size of data
%nMic = size( dataPulse, 2 );
nSamples = size( dataPulse, 3);

% X axes variables
ti = linspace(0,dataWidth(whichPulse), nSamples);

clf;

colors = [ linspace(1,0, nMic); linspace(0,1, nMic); linspace(0.25,0.75, nMic)];

% Original pulses
subplot(nRows, nCols, 1:4 );
PlotSinglePulse( whichPulse, nMic, dataPulse, dataWidth, peak, peaktime, colors );

% Put a line at the clip point
plot( [clipPerc * dataWidth(whichPulse) clipPerc * dataWidth(whichPulse)], [0 1.1*max(peak(whichPulse,1:nMic))], '-k');
text( clipPerc * dataWidth(whichPulse), 1.1*max(peak(whichPulse,1:nMic)), 'Clip');

% Fitted pulses
subplot(nRows, nCols, 5:8 );
for m = 1:nMic
    plot( ti, squeeze(dataPulse(whichPulse,m,:)), '--', 'Color', colors(:,m)' );
    hold on;
    plot(ti, g{whichPulse,m}(ti), 'Color', colors(:,m)', 'LineWidth', 2);
end
% Label the curves; put text on top
for m = 1:nMic
    text( peaktime(whichPulse,m), peak(whichPulse,m), sprintf('%0.0f',m), 'FontSize', 20, 'Color', colors(:,m)' );
end

xlabel('Time (ms)');
ylabel('Intensity');
title('Fitted data');


% Peak intensities and peak times
subplot(nRows, nCols, 9:12 );
IP = max( peak(whichPulse, 1:8) );
IT = max( peaktime(whichPulse, 1:8) );

plot( peak(whichPulse,1:8), '-k', 'LineWidth', 2 );
hold on;
plot( IP * peaktime(whichPulse,1:8) / IT, '--b', 'LineWidth', 2);
legend('Peak Intensity', 'Peak Time');

xlabel('Microphone');
ylabel('Intensity, Time (ms)');
title('Microphone distribution');

% Residual fit
subplot(nRows, nCols, 13:16 );
plot( resid(whichPulse,1:nMic), '-k', 'LineWidth', 2 );

xlabel('Microphone');
ylabel('Residual fit error');
title('Fit error');

for m = 1:8
    subplot( nRows, nCols, 16+m);
    plot( ti, squeeze(dataPulse(whichPulse,m,:)), '--', 'Color', colors(:,m)', 'LineWidth', 2 );
    hold on;
    plot(ti, g{whichPulse,m}(ti), 'Color', colors(:,m)', 'LineWidth', 2);
    title(sprintf('Microphone %0.0f', m));
    xlabel('Time (ms)');
    ylabel('Intensity');    
end

if nMic > 8
    for m = 9:nMic
        subplot( nRows, nCols, 23+m);
        plot( ti, squeeze(dataPulse(whichPulse,m,:)), '--', 'Color', colors(:,m)' );
        hold on;
        plot(ti, g{whichPulse,m}(ti), 'Color', colors(:,m)', 'LineWidth', 2);
        title(sprintf('Microphone %0.0f', m));
        xlabel('Time (ms)');
        ylabel('Intensity');    
    end
end
end

