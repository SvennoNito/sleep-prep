function ArtefactsCell = resample_artefacts(ArtefactsCell, SampleRate, EpochLength, MaxOldPoints, MaxNewPoints, OldPeriod)
arguments
    ArtefactsCell
    SampleRate
    EpochLength
    MaxOldPoints
    MaxNewPoints = floor(MaxOldPoints / SampleRate / EpochLength);
    OldPeriod = 1/SampleRate; % most detectors are for every sample point, but if not, specify what the period was
end

if iscell(ArtefactsCell)
    for ArtefactIdx = 1:numel(ArtefactsCell)
        ArtefactsCell{ArtefactIdx} = sprep.resample_matrix(ArtefactsCell{ArtefactIdx}, ...
            OldPeriod, EpochLength, SampleRate, MaxOldPoints, MaxNewPoints); 
    end
elseif isstruct(ArtefactsCell)
    fields = fieldnames(ArtefactsCell);
    for ifield = 1:numel(fields)
        field = fields{ifield};
        ArtefactsCell.(field) = sprep.resample_matrix(ArtefactsCell.(field), ...
            OldPeriod, EpochLength, SampleRate, MaxOldPoints, MaxNewPoints); 
    end
elseif ismatrix(ArtefactsCell)
    ArtefactsCell = sprep.resample_matrix(ArtefactsCell, ...
        OldPeriod, EpochLength, SampleRate, MaxOldPoints, MaxNewPoints); 
end