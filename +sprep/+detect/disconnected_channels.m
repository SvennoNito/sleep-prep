function [ArtefactsCorr, ArtefactsUncorr] = disconnected_channels(EEG, CorrelationWindow, MaxCorrelationThreshold, MinCorrelationThreshold, MinCorrChannelsMax, MinCorrChannelsMin, Overlap)
arguments
    EEG % should NOT be rereferenced from original recording!
    CorrelationWindow = 30; % seconds
    MaxCorrelationThreshold = .999;
    MinCorrelationThreshold = .3;
    MinCorrChannelsMax = 10;
    MinCorrChannelsMin = 5;
    Overlap = 0;
end

disp('Detecting disconnected channels')

[nChannels, nPoints]= size(EEG.data);
ArtefactsCorr       = false(nChannels, nPoints);
ArtefactsUncorr     = ArtefactsCorr;

% correlate in windows
[Starts, Ends] = sprep.utils.epoch_edges(CorrelationWindow, EEG.srate, nPoints);

% Overlap?
shift                   = floor((CorrelationWindow * EEG.srate) * Overlap);
Starts                  = unique(sort([Starts, Starts+shift]));
Ends                    = unique(sort([Ends, Ends+shift]));
Starts(Ends > nPoints)  = [];
Ends(Ends > nPoints)    = [];

% Pre-calculate diagonal indices to ignore self-correlation
diagIdx = 1:(nChannels+1):(nChannels^2);

for WindowIdx = 1:numel(Starts)
    % Extract window and calculate correlation matrix
    % Window is [nChannels x nSamples], so corr(Window') is [nChannels x nChannels]
    idxRange = Starts(WindowIdx):Ends(WindowIdx);
    R = corr(EEG.data(:, idxRange)');

    % Set diagonal to NaN so channels don't correlate with themselves
    R(diagIdx) = NaN;

    % VECTORIZED LOGIC: 
    % sum(R > threshold, 2) returns an [nChannels x 1] vector of counts
    countsMax = sum(R > MaxCorrelationThreshold, 2, 'omitnan');
    countsMin = sum(R > MinCorrelationThreshold, 2, 'omitnan');

    % Flag channels that meet criteria for this entire window
    ArtefactsCorr(countsMax >= MinCorrChannelsMax, idxRange)   = true;
    ArtefactsUncorr(countsMin <= MinCorrChannelsMin, idxRange) = true;
end

% Safety check: Only keep correlation artefacts if they affect a group of channels
% sum(..., 1) checks how many channels are flagged at each time point
globalCorrCount = sum(ArtefactsCorr, 1);
ArtefactsCorr(:, globalCorrCount < MinCorrChannelsMax) = false;

Artefacts = ArtefactsCorr | ArtefactsUncorr;