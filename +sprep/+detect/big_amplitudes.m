function Artefacts = big_amplitudes(EEG, VoltageThreshold, Padding)
arguments
    EEG
    VoltageThreshold        = 300; % maximum acceptable amplitude
    Padding                 = 1; % seconds; how much to pad artefacts; important when dealing with sharp edges, which when filtered can create little ripples around it
end

fprintf('Detecting large amplitudes\n')
Artefacts = false(size(EEG.data));

% 1. Compute deviations
Deviations = abs(EEG.data) > VoltageThreshold;

% 2. Apply padding left and right
ext_samples = round(Padding * EEG.srate);

% 3. Apply a moving maximum across the time dimension (dimension 2)
% The window [ext_samples ext_samples] looks 1s back and 1s forward
Artefacts = logical(movmax(Deviations, [ext_samples ext_samples], 2));