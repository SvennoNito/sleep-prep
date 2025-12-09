function [AllArtefacts, X, Y] = merge_artefacts(ArtefactsCell, MergeType)
arguments
    ArtefactsCell
    MergeType = 'or';
end

if isstruct(ArtefactsCell)
    fields = fieldnames(ArtefactsCell);
    ArtefactsCell = struct2cell(ArtefactsCell);
end

AllArtefacts = false(size(ArtefactsCell{1}));
for ArtefactIdx = 1:numel(ArtefactsCell)
    switch MergeType
        case 'or'
            AllArtefacts = AllArtefacts | ArtefactsCell{ArtefactIdx};
        case 'sum'
        A = ArtefactsCell{ArtefactIdx};
        X = min(size(A, 1), size(AllArtefacts, 1));
        Y = min(size(A, 2), size(AllArtefacts, 2));
            AllArtefacts = AllArtefacts(1:X, 1:Y) + A(1:X, 1:Y);

    end
end