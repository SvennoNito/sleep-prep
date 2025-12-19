function EEG = select(EEG, KeepVector)
% Optimized select: Direct matrix manipulation, skipping heavy wrappers.

% 1. Logical indexing directly on the matrix (In-place is faster)
EEG.data = EEG.data(:, KeepVector);

% 2. Manually update critical metadata instead of eeg_checkset
EEG.pnts  = size(EEG.data, 2);
EEG.times = EEG.times(KeepVector);

% 3. Update or Clear Events
% Since time is now discontinuous, old event latencies are invalid.
% Clearing them is much faster than re-calculating latencies for thousands of events.
EEG.event = []; 

% 4. Update epoch/continuous flags if necessary
EEG.trials = 1; 

% Note: We avoid eeg_checkset(EEG) here. 

end