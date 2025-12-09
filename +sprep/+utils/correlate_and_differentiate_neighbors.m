function [Correlations, DifferenceRatios, MostCorrCh] = correlate_and_differentiate_neighbors(EEG, HighPassFilter, LowPassFilter, CorrWindow, STDWindow)
arguments
    EEG
    HighPassFilter = 0.5;
    LowPassFilter = 6;
    CorrWindow = 4; % in seconds
    STDWindow = 60*5;
end

%%%%%%%%%%
%%% setup

% set up dimentions
nChannels = size(EEG.data, 1);
nPoints = size(EEG.data, 2);
SampleRate = EEG.srate;

CorrWindow = CorrWindow*SampleRate;
STDWindow = STDWindow*SampleRate;

ChannelIndexes = 1:nChannels;

% identify neighboring channels
Neighbors = sprep.utils.find_neighbors(EEG.chanlocs);

% set up blanks
Correlations = single(nan(nChannels, nPoints));
DifferenceRatios = Correlations;
MostCorrCh = Correlations;

%%%%%%%
%%% Run

% filter data
EEG = pop_eegfiltnew(EEG, HighPassFilter, []);
EEG = pop_eegfiltnew(EEG, [], LowPassFilter);

% reference to average
EEG = pop_reref(EEG, []);

% get moving standard deviation of each channel
STD = single(movstd(EEG.data', STDWindow))';

for ChannelIdx = 1:nChannels

    % get neighbors of current channel
    NeighborChannels = unique(ChannelIndexes(Neighbors(ChannelIdx, :)));

    % set up blanks
    R_neighbors = nan(numel(NeighborChannels), nPoints);
    D_neighbors = R_neighbors;
    
    for Idx = 1:numel(NeighborChannels)
        
        NeighborIdx = NeighborChannels(Idx);

        % performing moving correlation of channel with a given neighbor
        R_neighbors(Idx, :) = sprep.external.movcorr(EEG.data(ChannelIdx, :)', ...
            EEG.data(NeighborIdx, :)', CorrWindow);

        % get ratio of difference between channel and neighbor to the
        % moving standard deviation of the neighbor. 
        Diff = abs(EEG.data(ChannelIdx, :)-EEG.data(NeighborIdx, :));
        D_neighbors(Idx, :) = Diff./STD(NeighborIdx, :);
    end

    % keep only the highest correlation values at each time point
    [Correlations(ChannelIdx, :), MaxCorrIndexes] = max(R_neighbors, [], 1);
    MostCorrCh(ChannelIdx, :) = NeighborChannels(MaxCorrIndexes);

    % using the same highly correlated channel at each time point, select
    % the difference ratios
    linearIndices = sprep.utils.get_linear_indices(R_neighbors, MaxCorrIndexes);
    DifferenceRatios(ChannelIdx, :) = D_neighbors(linearIndices);

    disp(['Finished correlating channel ', num2str(ChannelIdx)])
end

% save some space
% Correlations = single(Correlations);
% DifferenceRatios = single(DifferenceRatios);
% MostCorrCh = single(MostCorrCh);

