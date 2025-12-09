function [Starts, Ends] = detect_sleep_cycles(Scoring, EpochLength, MinTime, opts)
arguments
    Scoring
    EpochLength
    MinTime = 10; % minutes
    opts.stagemap = dictionary( ...
        'W', 1, ...
        'REM', 0, ...
        'N1', -1, ...
        'N2', -2, ...
        'N3', -3 ...
        );
end

% ignore n1 and wake by assigning them to the previous stage
Scoring(1) = opts.stagemap('N2'); % assign first score to NREM sleep so that the next code can reassign wake and n1 appropriately
Scoring = sprep.scoring.reassign_n1(Scoring, opts.stagemap('N2'));
Scoring = sprep.scoring.reassign_n1(Scoring, opts.stagemap('W'));
Scoring(Scoring<0) = -1;

% NREM bouts
NREM = ...
    ismember(Scoring, opts.stagemap('N1')) | ...
    ismember(Scoring, opts.stagemap('N2')) | ...
    ismember(Scoring, opts.stagemap('N3'));
[Starts, Ends] = sprep.utils.data2windows(NREM);

Durations = (Ends+1-Starts)*EpochLength;

Troughs = Starts(Durations>MinTime*60); % start of NREM/wake

Starts = Troughs;
Ends = Troughs(2:end)-1;
Ends(end+1) = numel(Scoring);

Starts(Starts==numel(Scoring)) = []; % exclude start if its the last epoch
Ends = unique(Ends); % in case adding numel(scoring) duplicated the end