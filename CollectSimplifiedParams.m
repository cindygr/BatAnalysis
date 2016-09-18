function [ kmeansParams, kmeansMeans ] = CollectSimplifiedParams( nMic, g, resid, peak, peaktime, bNormalize, bIncludePeak )
%CollectSimplifiedParams Turn the simplified data into an nPulse X #
%variables feature vector
%   Basically flattening out data; do some normalization to avoid bias
%   because of where the pulse cutoffs were placed
%
% bNormalize: If true, make all the variables have a mean of zero and sd of
% 1 (more or less)

%Data sizes
nPulses = size( peak, 1);

% # of parameters per type
nFit = 3;
nResid = 1;
nPeak = 1;
nPeakTime = 1;
if bIncludePeak
    nParams = nFit + nResid + nPeak + nPeakTime;
else
    nParams = nFit + nResid;
end
kmeansParams = zeros( nPulses, nParams * nMic );
kmeansMeans = zeros( nPulses, nParams );
kmeansVar = zeros( nPulses, nParams );

for p = 1:nPulses
    iParam = 1;
    micParams = zeros(nMic, nParams);
    for m = 1:nMic
        micParams(m,1) = g{p,m}.a1;
        micParams(m,2) = g{p,m}.b1;
        micParams(m,3) = g{p,m}.c1;
    end
    % Normalize the mean location by expressing as a shift from the average
    % because there may be some error in clipping the pulse
    meanB1 = mean( micParams(:,2) );
    micParams(:,2) = meanB1 - micParams(:,2);
    iParam = iParam + 3;
    
    micParams(:, iParam) = squeeze(resid(p,1:nMic))';
    iParam = iParam+1;
    if bIncludePeak
        micParams(:, iParam) = squeeze(peak(p,1:nMic)) - mean(peak(p, 1:nMic) )';
        iParam = iParam+1;
        micParams(:, iParam) = squeeze(peaktime(p,1:nMic)) - mean(peaktime(p, 1:nMic))';
        iParam = iParam+1;
    end
    
    kmeansParams(p,:) = reshape( micParams, [1, nParams * nMic] );
    kmeansMeans(p,:) = mean(micParams);
    kmeansVar(p,:) = std(micParams);
end


if bNormalize
    center = mean( kmeansMeans );
    scl = mean( kmeansVar );
    fprintf('Center %0.6f \n', center);
    fprintf('Scale %0.6f \n', scl);
    for p = 1:nPulses
        data = reshape( kmeansParams(p,:), [ nMic, nParams] );
        for k = 1:nParams
            data(:,k) = (data(:,k) - center(k)) / scl(k);
        end
        kmeansParams(p,:) = reshape( data, [1, nParams * nMic] );
    end
end
end

