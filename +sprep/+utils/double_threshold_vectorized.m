function Artefacts = double_threshold_vectorized(Data, LowerThreshold, UpperThreshold)
% Efficient Hysteresis Thresholding using Connected Components

if LowerThreshold >= UpperThreshold
    error('Lower threshold is larger than upper threshold')
end

[nChans, nPnts] = size(Data);
Artefacts = false(nChans, nPnts);

% Pre-calculate logical masks
AboveLower = Data > LowerThreshold;
AboveUpper = Data > UpperThreshold;

% Process each channel
for c = 1:nChans
    % 1. Identify "islands" of data above the lower threshold
    % bwlabel treats the row as a 1D image and gives each island a unique ID
    [labels, numIslands] = bwlabel(AboveLower(c, :));
    
    if numIslands == 0, continue; end
    
    % 2. Find which label IDs are present in the "AboveUpper" mask
    % These are the islands that reached the high threshold
    validLabels = unique(labels(AboveUpper(c, :)));
    
    % Remove the 0 label (background) if it exists
    validLabels(validLabels == 0) = [];
    
    % 3. Keep only the islands that contain a peak above UpperThreshold
    % ismember creates a logical mask of the entire original island
    Artefacts(c, :) = ismember(labels, validLabels);
end


