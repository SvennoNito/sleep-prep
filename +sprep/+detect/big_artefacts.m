function Artefacts = big_artefacts(EEG, VoltageThreshold, DiffVoltageThreshold, Padding)
arguments
    EEG
    VoltageThreshold = 1000; % maximum acceptable voltage
    DiffVoltageThreshold = 100; % maximum acceptable difference from one point to the next
    Padding = 1; % seconds; how much to pad artefacts; important when dealing with sharp edges, which when filtered can create little ripples around it
end

nChannels = size(EEG.data, 1);
fs = EEG.srate;
Artefacts = false(size(EEG.data));

disp('Detecting large artefacts in EEG')

for ChannelIdx = 1:nChannels
    Signal = EEG.data(ChannelIdx, :);
    Cuts = abs(diff([Signal, 0])) > DiffVoltageThreshold | abs(Signal) > VoltageThreshold;
    Artefacts(ChannelIdx, :) = sprep.utils.pad_windows(Cuts, Padding*fs);
end


