dataset = 1;

if ~exist('dataPulse', 'var') || ~exist('dataWidth', 'var')
    [dataPulse, dataWidth] = ReadPulseData( sprintf('9-15bat/%0.0f/', dataset) );
end

% Where to clip the pulse at
clipPerc = 0.7;
% Generate per-pulse data
if ~exist('g', 'var') || ~exist('resid', 'var') || ~exist('peak', 'var') || ~exist('peaktime', 'var')
    [ g, resid, peak, peaktime ] = SimplifyPulse( dataPulse, dataWidth, clipPerc );
    for k = 1:size(dataPulse,1)
        clf
        PlotPulse( k, nMic, dataPulse, dataWidth, clipPerc, g, resid, peak, peaktime );
        savefig( sprintf('Clustering results/Pulse_%2.0f.fig', k') );
    end
end

% Save data
save( 'SimplifiedData.mat', 'dataPulse', 'dataWidth', 'g', 'peak', 'peaktime', 'resid' );

%Data sizes
nPulses = size( dataPulse, 1);
nMic = 8;
nSamples = size( dataPulse, 3);

%Plot one to see if data looks ok
figure(1)
PlotPulse( 5, nMic, dataPulse, dataWidth, clipPerc, g, resid, peak, peaktime );

% Get parameters for kmeans from the simplified data
[simplifiedParams, simplifiedMeans] = CollectSimplifiedParams( nMic, g, resid, peak, peaktime, true, false );
% Looks like 4 is about right
spSimple = StableClusters(simplifiedParams);
PlotStablePairs(squeeze(spSimple(4,:,:)), nMic, dataPulse, dataWidth, resid, peak, peaktime, g );

% Do the same for the raw data
dataFirstEight = dataPulses(:, 1:8, :);
dataMicLinear = reshape( dataFirstEight, [size(dataFirstEight,1), size(dataFirstEight,2) * size(dataFirstEight,3)] );

spRaw = StableClusters(dataMicLinear);
PlotStablePairs(squeeze(spRaw(4,:,:)), nMic, dataPulse, dataWidth, resid, peak, peaktime, g );

% Now do for data motion
dataMotion = csvread('batmotion.csv');
% Get 4 motion numbers
spMotion = StableClusters(dataMotion(:, 2:4));
PlotStablePairs(squeeze(spMotion(3,:,:)), nMic, dataPulse, dataWidth, resid, peak, peaktime, g );


% nClusters = 5;
% [idx, c] = kmeans( kmeansParams, 5 );
% 
% nRows = 3;
% nCols = 7;
% for k = 1:nClusters
%     figure(k+1);
%     clf
%     
%     count = 1;
%     fprintf('Cluster %0.0f, n %0.0f:  ', k, sum( idx == k) );
%     for j = 1:nPulses
%         subplot(nRows, nCols, count);
%         if idx(j) == k
%             hold off;
%             for m = 1:nMic
%                 plot( linspace(0,dataWidth(j), nSamples), squeeze(dataPulse(j,m,:)) )
%                 hold on;
%             end
%             fprintf('%0.0f ', j);
%             title(sprintf('Pulse %0.0f', j) );
%             count = count + 1;
%         end
%     end
%     fprintf('\n');
% end
% 
% 
% 
% 

clf
nRows = 2;
nCols = 4;
strs = {'Int', 'Mean', 'Var', 'resid', 'peak', 'peakTime'};
for k = 1:size(simplifiedMeans,2)
    subplot( nRows, nCols, k)
    plot( simplifiedMeans(:,k) );
    title(strs{k});
end

a1s = reshape( squeeze( simplifiedParams(:, 1:6:end ) ), [nPulses * nMic, 1] );
b1s = reshape( squeeze( simplifiedParams(:, 2:6:end ) ), [nPulses * nMic, 1] );
pis = reshape( squeeze( simplifiedParams(:, 5:6:end ) ), [nPulses * nMic, 1] );
pts = reshape( squeeze( simplifiedParams(:, 6:6:end ) ), [nPulses * nMic, 1] );
scatter( a1s, pis);
scatter( b1s, pts);
