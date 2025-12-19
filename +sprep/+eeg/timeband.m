function EEGBand = timeband(EEG, Range)

EEGBand = EEG;

% filter
% FiltEEG = pop_eegfiltnew(EEG, Range(1), []);
% FiltEEG = pop_eegfiltnew(FiltEEG, [], Range(2));
FiltEEG = pop_eegfiltnew(EEG, Range(1), Range(2)); % twice faster

% hilbert
EEGBand.data = (abs(hilbert(FiltEEG.data'))').^2;