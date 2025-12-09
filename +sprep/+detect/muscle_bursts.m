function [Artefacts, SmoothData, Thresholds] = muscle_bursts(EEG, RangeMuscle, MedianMultiplierThresholds, SmoothWindow, Artefacts)
arguments
    EEG
    RangeMuscle = [20 45];
    MedianMultiplierThresholds = [20 100]; % x times the median for a burst threshold
    SmoothWindow = 0.2; % seconds
    Artefacts = logical(zeros(size(EEG.data)))
end

disp('Detecting muscle artefacts')

% EEG = pop_reref(EEG, []);

% get data into bands
MuscleEEG = sprep.eeg.timeband(EEG, RangeMuscle);

SmoothData = sprep.eeg.smooth(MuscleEEG, SmoothWindow, 'mean');

ThresholdData = SmoothData.data;
ThresholdData(Artefacts) = nan;

Thresholds = MedianMultiplierThresholds.*median(ThresholdData, 'all', 'omitmissing');

Artefacts = sprep.utils.double_threshold(SmoothData.data, Thresholds(1), Thresholds(2));

% %%
% figure('Position', [50 50 500 250], 'color', 'w');
% hold on;
% plotme = SmoothData.data(1,:);
% plot(plotme)
% yline(Thresholds)
% ylim([0 max(Thresholds)*1.2])
% plotme(~Artefacts(1,:)) = nan;
% plot(plotme, 'r')
% xlim([0, 200*30])
