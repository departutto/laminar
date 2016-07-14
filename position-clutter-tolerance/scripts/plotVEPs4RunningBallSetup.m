% Photocell events.
indices = find(eventDescriptors(:, 2) == 128)';

% Time interval between two consecutive photocell events (presumably in sec).
durations = eventTimestamps(indices(2:end)) - eventTimestamps(indices(1:end - 1));

% Detect stimulus onset and offset (the cut-off values are in sec). The
% first and second rows correspond to stimulus onset and offset.
stimIndices = [indices(1:end - 1); indices(2:end)];
stimIndices = stimIndices(:, durations >= 0.46 & durations <= 0.49);
stimTimings = [eventTimestamps(stimIndices(1, :)); eventTimestamps(stimIndices(2, :))];

% Raw LFP fragments per stimulus presentation.
lfpFragments = [];

% Number of LFP fragments.
nFragments = size(stimTimings, 2);

% Number of data points per LFP fragment before and after stimulus onset.
beforeOnset  = -0.3; % sec
beforePoints = round(abs(beforeOnset * samplingFreq)); 
afterOnset   = 0.6;  % sec 
afterPoints  = round(abs(afterOnset * samplingFreq));

% Retrieve LFP fragments per stimulus presentation.
fprintf('Iteration #');
for counter = 1:nFragments
    fprintf('%5d', counter);
    stimOnset    = stimTimings(1, counter);
    [val, index] = min(abs(lfpTimestamps - stimOnset));
    if index - beforePoints < 1 || index + afterPoints > length(rawSignal)
        continue;
    end
    lfpFragments(end + 1, :) = rawSignal(index - beforePoints:index + afterPoints);
    if counter ~= nFragments
        fprintf('\b\b\b\b\b');
    end
end
fprintf('\n');

% Compute visually evoked potentials.
rawVEP      = mean(lfpFragments); % median or mean!!!
% Moving average with a time window of 20 ms (period of 50-Hz oscillations)
% given a sampling frequency of 32 kHz.
smoothedVEP = tsmovavg(rawVEP', 's', 640, 1);

% Plot VEPs.
figure;
subplot(1, 2, 1), plot(rawVEP, '-b'), hold on;
plot([beforePoints + 1 beforePoints + 1], get(gca, 'YLim'), '--k');
xlim([1 beforePoints + 1 + afterPoints]), set(gca, 'XTick', []);
set(gca, 'XTick', [1 beforePoints + 1 beforePoints + 1 + afterPoints]);
set(gca, 'XTickLabel', {beforeOnset, 0, afterOnset});
xlabel('time, sec'), ylabel('signal, uV'), title(['VEP: N = ' num2str(size(lfpFragments, 1)) ' LFP fragments'])

subplot(1, 2, 2), plot(smoothedVEP, '-r'), hold on;
plot([beforePoints + 1 beforePoints + 1], get(gca, 'YLim'), '--k');
xlim([1 beforePoints + 1 + afterPoints]), set(gca, 'XTick', []);
set(gca, 'XTick', [1 beforePoints + 1 beforePoints + 1 + afterPoints]);
set(gca, 'XTickLabel', {beforeOnset, 0, afterOnset});
xlabel('time, sec'), ylabel('signal, uV'), title('Smoothed VEP');

% Clear all unnecessary variables.
clear *ndices durations stimTimings nFragments *Onset *Points counter val index;
