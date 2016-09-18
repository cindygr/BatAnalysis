function [ g, resid, peak, peaktime ] = SimplifyPulse( dataPulse, dataWidth, clipPerc )
% Fit a gaussian to the n microphone signals (g)
%   Gaussian range is 0 to clipPerc
% dataPulse is a matrix, each row a microphone, each column the signal
% intensity
% dataWidth is the with of the pulse in milli seconds.
% clipPerc is used to clip off the right hand side of the signal
% Save the residual error (resid)
%
% Return the peak for each of the microphones as an array (1-8)
% Return the time of the peak as well

nPulse = size( dataPulse, 1 );
nMic = size( dataPulse, 2 );

% Ditch the bumpy stuff at the end of the signal
dataRange = round( clipPerc * size(dataPulse,3) );

g = cell( nPulse, nMic ); % Gaussian is returned as a cell structure
resid = zeros( nPulse, nMic ); % Error in the fit
peak = zeros( nPulse, nMic ); % Where the peak is for each microphone, range 0-1
peaktime = zeros( nPulse, nMic ); % Where the peak is for each microphone, range 0-1

for p = 1:nPulse
    fprintf('Processing pulse %0.0f of %0.0f\n', p, nPulse);
    xi = linspace(0,clipPerc * dataWidth(p), dataRange);
    for m = 1:nMic
        g{p, m} = fit( xi', squeeze( dataPulse(p, m, 1:dataRange) ), 'gauss1' );
        fittedYI = g{p,m}(xi);
        YI = squeeze(dataPulse(p, m, 1:dataRange));
        [peak(p, m),indx] = max( dataPulse(p, m, 1:dataRange) );
        peaktime(p, m) = xi(indx);
        resid(p, m) = mean( (YI - fittedYI).^2 ) / peak(p,m); % Normalize
    end
end

end

