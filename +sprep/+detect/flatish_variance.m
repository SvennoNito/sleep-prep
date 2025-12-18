function Artefacts = flatish_variance(EEG, MovSDWindow, SDThreshold, Padding)
arguments
    EEG
    MovSDWindow = 10; % in seconds; does a moving standard deviation, and sees if it's below SD threshold. NB: the higher this is, the higher SD threshold can be without capturing EEG from channels close to the reference
    SDThreshold = .1;
    Padding     = 5;
end

fprintf('Detecting flatish lines\n')
Artefacts = false(size(EEG.data));

% 1. Compute moving standard deviation
Signal_std      = movstd(EEG.data, MovSDWindow*EEG.srate, 0, 2);
Variance_std    = movstd(Signal_std, MovSDWindow*EEG.srate, 0, 2);

% 2. Find deviations
Deviations = Variance_std < SDThreshold;

% 3. Apply padding left and right
ext_samples = round(Padding * EEG.srate);

% 4. Apply a moving maximum across the time dimension (dimension 2)
% The window [ext_samples ext_samples] looks 1s back and 1s forward
Artefacts = logical(movmax(Deviations, [ext_samples ext_samples], 2));