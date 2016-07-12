% Photocell events.
indices = find(eventDescriptors == 32);

% Time interval between two consecutive photocell events (presumably in sec).
durations = eventTimestamps(indices(2:end)) - eventTimestamps(indices(1:end - 1));

% Detect stimulus onset and offset (the cut-off values are in sec). The
% first and second rows correspond to stimulus onset and offset.
stimIndices = [indices(1:end - 1); indices(2:end)];
stimIndices = stimIndices(:, durations >= 0.3 & durations <= 0.6);
stimTimings = [eventTimestamps(stimIndices(1, :)); eventTimestamps(stimIndices(2, :))];

% Raw LFP fragments per stimulus presentation.
lfpFragments = [];

% Number of LFP fragments.
nFragments = size(stimTimings, 2);

% Number of data points per LFP fragment before and after stimulus onset.
beforeOnset = 10000; % = 312.5 ms at the sampling frequency of 32 kHz.
afterOnset  = 10000;

% Retrieve LFP fragments per stimulus presentation.
for counter = 1:nFragments
    stimOnset    = stimTimings(1, counter);
    [val, index] = min(abs(lfpTimestamps - stimOnset));
    lfpFragments(end + 1, :) = rawSignal(index - beforeOnset:index + afterOnset);
end

% Compute visually evoked potentials.
rawVEP      = mean(lfpFragments);
% Moving average with a time window of 20 ms (one period of 50-Hz oscillations).
smoothedVEP = tsmovavg(rawVEP', 's', 640, 1);

% Plot VEPs.
figure;
subplot(1, 2, 1), plot(rawVEP, '-b'), hold on;
plot([beforeOnset + 1 beforeOnset + 1], get(gca, 'YLim'), '--k');
xlim([1 beforeOnset + 1 + afterOnset]), set(gca, 'XTick', []);
xlabel('timestamp'), ylabel('signal, uV'), title('Average VEP')

subplot(1, 2, 2), plot(smoothedVEP, '-r'), hold on;
plot([beforeOnset + 1 beforeOnset + 1], get(gca, 'YLim'), '--k');
xlim([1 beforeOnset + 1 + afterOnset]), set(gca, 'XTick', []);
xlabel('timestamp'), ylabel('signal, uV'), title('Smoothed average VEP');

% Clear all unnecessary variables.
clear *ndices durations stimTimings nFragments *Onset counter val index;
