function Artefacts = big_differences(EEG, DiffVoltageThreshold, Padding, MillisecondExtension)
arguments
    EEG
    DiffVoltageThreshold    = 300; % maximum acceptable difference from one point to the next
    Padding                 = 1; % seconds; how much to pad artefacts; important when dealing with sharp edges, which when filtered can create little ripples around it
    MillisecondExtension    = 50;
end

fprintf('Detecting large differences\n')
Artefacts = false(size(EEG.data));

% 1. Define the window range (e.g., 50ms)
range = floor(MillisecondExtension/1000 * EEG.srate);

% 2. Get the max and min values in the future window [0 range]
% We use the current data directly to avoid manual shifting
future_max = movmax(EEG.data, [0 range], 2, 'Endpoints', 'shrink');
future_min = movmin(EEG.data, [0 range], 2, 'Endpoints', 'shrink');

% 3. Calculate differences from the current point
diff_to_max = abs(future_max - EEG.data);
diff_to_min = abs(future_min - EEG.data);

% 4. The biggest difference is the larger of the two absolute distances
AmplitudesDiff = max(diff_to_max, diff_to_min);

% 5. Compute deviations
Deviations = abs(AmplitudesDiff) > DiffVoltageThreshold;

% 6. Apply padding left and right
ext_samples = round(Padding * EEG.srate);

% 7. Apply a moving maximum across the time dimension (dimension 2)
% The window [ext_samples ext_samples] looks 1s back and 1s forward
Artefacts = logical(movmax(Deviations, [ext_samples ext_samples], 2));