function NewMatrix = resample_matrix(Matrix, old_period, new_period, SampleRate, NPoints, nNewEpochs)
% this is specifically for when data in Matrix is categorical, and so you
% jut want the majority score for a new window.
% Note, this is a slightly convoluted method, that first upsamples any
% matrix to the original size of the EEG array, then downsamples it; this
% is to make sure everything ultimately matches the original EEG.
arguments
    Matrix
    old_period
    new_period % if isempty, it will assume you just want the EEG srate
    SampleRate
    NPoints
    nNewEpochs = [];
end

% disp('Resampling matrix (inefficient code)')

nChannels = size(Matrix, 1);

if ~isempty(nNewEpochs)
    if islogical(Matrix)
    else
        NewMatrix = nan(nChannels, nNewEpochs);
    end
else
    if islogical(Matrix)
        NewMatrix = false(nChannels, numel(1:new_period:(NPoints/SampleRate)));
    else
        NewMatrix = nan(nChannels, numel(1:new_period:(NPoints/SampleRate)));
    end
end

for ChannelIdx = 1:nChannels
    Array = sprep.utils.resample_array(Matrix(ChannelIdx, :), ...
        old_period, new_period, SampleRate, NPoints, 'max', nNewEpochs);

    NewMatrix(ChannelIdx, 1:numel(Array)) = Array;
end