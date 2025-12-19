function EEG = smooth(EEG, SmoothSpan, Type)

fprintf('Smoothing EEG using %s filter...\n', Type);

% 1. Calculate span in samples once
span = round(SmoothSpan * EEG.srate);

% 2. Vectorized smoothing across the time dimension (Dim 2)
% We specify '2' to tell MATLAB to smooth across columns (time) for every row (channel)
switch lower(Type)
    case 'mean'
        EEG.data = movmean(EEG.data, span, 2);
    case 'median'
        EEG.data = movmedian(EEG.data, span, 2);
    otherwise
        % Note: 'smooth' is from the Curve Fitting Toolbox and is generally 
        % slower than movmean. For large matrices, it's better to default to movmean.
        for ChannelIdx = 1:size(EEG.data, 1)
            EEG.data(ChannelIdx, :) = smooth(EEG.data(ChannelIdx, :), span);
        end
end