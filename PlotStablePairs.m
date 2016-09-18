function [  ] = PlotStablePairs( stablePairs, nMic, dataPulse, dataWidth, resid, peak, peaktime, fittedG )
%PlotStablePairs Show graphs of stable pairs

% make figures
iFig = 3;

% Size of things
nPulses = size( stablePairs,1 );
nSamples = size( dataPulse, 3);

% keep track of groups visited
visited = zeros( size(stablePairs,1), 1) ~= 0;

% For plotting
colors = [ linspace(1,0, nMic); linspace(0,1, nMic); linspace(0.25,0.75, nMic)];

nRows = 4;
nCols = 6;
while sum( visited == false ) > 0
    figure(iFig);
    clf;
    
    iFind = find( visited == false, 1 );
    group = iFind;
    iCount = 0;
    visited(iFind) = true;
    
    while iCount < length(group)
        iTry = group(iCount+1);
        iCount = iCount + 1;
        inGroup = find( visited == false & stablePairs(iTry,:)' );
        visited(inGroup) = true;
        group = unique( [group;  inGroup] );
    end
    fprintf('Cluster %0.0f  ', length( group ) );
    fprintf('%0.0f ', group);
    fprintf('\n');
    
    if ( length(group) > 2 ) 
        % Raw pulse data
        nRows = 3;
        nCols = ceil( 2* length(group) / nRows );
        for g = 1:length(group)
            subplot(nRows, nCols, g);
            PlotSinglePulse( group(g), nMic, dataPulse, dataWidth, peak, peaktime, colors );
            title(sprintf('Pulse %0.0f', group(g) ) );
        end
        % Data per microphone
        for g = 1:length(group)
            subplot(nRows, nCols, length(group) + g);
            PlotArrayPulse( group(g), peak, peaktime, resid, fittedG );
            title(sprintf('Pulse %0.0f', group(g) ) );
        end
        legend('Peak Intensity', 'Peak Time', 'Resid', 'Int', 'Mean', 'Var');

        iFig = iFig + 1;
    end
end

