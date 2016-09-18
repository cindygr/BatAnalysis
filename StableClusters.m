function [ stablePairs ] = StableClusters( dataToClusterOn )
%StableClusters Just keep doing clusters and see how many times x is
%correlated with y
%   Detailed explanation goes here

nPulses = size( dataToClusterOn,1 );
nMaxClusters = 5;
nTry = 20;
dCutoff = 0.85;

nStable = zeros(nMaxClusters, nPulses, nPulses);
dSumMean = zeros(nMaxClusters, nTry );
stablePairs = zeros(nMaxClusters, nPulses, nPulses) == 0;

figure(2)
clf;
nRows = 2;
nCols = 4;
for k = 2:nMaxClusters
    nPer = zeros( k, 1);
    for t = 1:nTry
        [idx, ~, sumD] = kmeans( dataToClusterOn, k );
        dSumMean(k,t) = mean( sumD );
        fprintf('Cluster %0.0f %0.2f:\n', k, dSumMean(k,t) );
        for j = 1:k
            nPer(j) = sum(idx == j);
            fprintf('  %0.0f %0.2f\n', sum( idx == j), sumD(j) );
        end
        fprintf('\n');

        subplot(nRows, nCols, 1);
        plot( ones(k,1) * k + 0.01 * t, sumD, '+b' );
        hold on;
        
        subplot(nRows, nCols, 3);
        plot( ones(k,1) * k + 0.05 * t, nPer, '+k' );
        hold on;
        title('Cluster size');
        
        for p1 = 1:nPulses
            for p2 = p1+1:nPulses
                if idx(p1) == idx(p2)
                    nStable(k, p1, p2) = nStable(k, p1,p2) + 1;
                    nStable(k, p2, p1) = nStable(k, p2,p1) + 1;
                end
            end
        end
    end            
    nStable(k,:,:) = nStable(k,:,:) / nTry;
    
    subplot(nRows, nCols, 1);
    plot( ones(nTry,1) * k + 0.01, dSumMean(k,t), 'Xk', 'MarkerSize', 20 );
    hold on;
    title('Mean DSum');
    
    subplot(nRows, nCols, 2);
    plot( ones(nTry,1) * k, sum( sum( nStable(k,:,:) > dCutoff) ), 'Xk' );
    hold on;
    title('Stable pairs');
    
    subplot( nRows, nCols, 2 + k );
    for p1 = 1:nPulses
        for p2 = p1+1:nPulses
            if nStable(k,p1,p2) > dCutoff
                %fprintf('%0.0f-%0.0f\n', p1, p2);
                plot(p1, p2, 'X');
                hold on;
            end
        end
    end
    title(sprintf('k=%0.0f', k));
    
    stablePairs(k,:,:) = nStable(k,:,:) > dCutoff;
end


end