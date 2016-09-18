function [ dataPulses, dataWidth ] = ReadPulseData( strLoc )
%ReadPulseData Read in pulse data
%   Read in the raw signal and the pulse start and stop times
%   dataPulse is a 3D matrix, # of pulses, # of microphones by # of samples
%  # of samples is set to be about the size of the largest number of
%  samples (resample data so all same size)
%  dataWidth is the original width of the pulse, in milliseconds

% Set to true if you want to plot result
bPlot = false;

% Start and stop times
dataPulseTimeList = load( sprintf('%s/pulse_timelist.mat', strLoc) );

% Raw signal data
dataSignal = load(sprintf('%s/out.mat', strLoc));

% Convert to pulses
% The start and stop time are in milliseconds
%   fs has the frame rate per second
%   So convert to seconds then find number of samples to use
timeStart =  round( dataPulseTimeList.time_start * dataSignal.fs / 1000 );
timeEnd =  round( dataPulseTimeList.time_end * dataSignal.fs / 1000 );

% Longest pulse
maxSigLen = max( timeEnd - timeStart );
% Resample signals to be the same number of samples
nSamples = ceil( maxSigLen * 1.01 );

% number of microphones
nMic = size( dataSignal.out, 2 );
% number of pulses
nPulses = length(timeStart);

% Matrix to store data in (# pulses X # microphones X # samples)
dataPulses = zeros( nPulses, nMic, nSamples );
% Store in seconds (undo time conversion from above)
%    Should be same as dataPulseTimeList.time_end - dataPulseTimeList.start_end
dataWidth = (timeEnd - timeStart) * 1000 / dataSignal.fs;
for P = 1:nPulses
    ts = timeStart(P);
    te = timeEnd(P);
    
    % Signal for all microphones for this pulse
    dataRaw = dataSignal.out(ts:te, : );
    
    % Resample by # samples
    nOriginalSamples = size(dataRaw,1);
    if bPlot
        clf
    end
    for m = 1:nMic        
        % Convert from signal to intensity
        dataIntensity = abs( hilbert(dataRaw(:,m)) );

        dataPulses(P, m, :) = interp1( 1:nOriginalSamples, dataIntensity, linspace(1, nOriginalSamples, nSamples) );
        if bPlot
            plot( squeeze( dataPulses(P,m,:)));
            hold on;
        end
    end
end

end

