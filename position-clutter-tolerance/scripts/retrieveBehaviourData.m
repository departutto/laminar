[fileName, pathName] = uigetfile('*.nev', 'Select Events file (*.nev)');
if ~fileName
    clear fileName pathName;
    return;
else
    fprintf('Events file: %s%s\n', pathName, fileName);
end

[timeStamps, ttls] = Nlx2MatEV([pathName fileName], [1 0 1 0 0], 0, 1, 1);
time0              = timeStamps(1);
timeStamps         = (timeStamps - time0) / 10 ^ 6;
photoCellEvents    = bitand(ttls, 3);
events             = bitshift(ttls, -2);
consolidated       = [timeStamps' events' photoCellEvents'];

clear fileName pathName timeStamps ttls photoCellEvents events;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find indices of the events corresponding to the beginning of trials.
trialStart = find(consolidated(:, 2) == 254);

% All must be 0.
if any(consolidated(trialStart + 1, 2)) || ...
   any(consolidated(trialStart + 3, 2)) || ...
   any(consolidated(trialStart + 5, 2)) 
    error('Corrupted header structure (1)!');
end

% Extract header ends.
headerEnds = unique(consolidated(trialStart + 6, 2));
if length(headerEnds) > 1 || headerEnds ~= 253
    error('Corrupted header structure (1)!');
end

% Extract the experiment type.
experimentType = unique(consolidated(trialStart + 2, 2));
if length(experimentType) > 1
    error('Multiple experiment identifiers!');
end
fprintf('Experiment type: %d\n', experimentType);

% Extract stimulus conditions.
conditions = consolidated(trialStart + 4, 2);

clear headerEnds;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment.trial = struct([]);
experiment.type  = experimentType;

for i = 1:length(trialStart)
    experiment.trial(i).onset     = consolidated(trialStart(i), 1);
    experiment.trial(i).condition = conditions(i);
end

fprintf('Total number of detected trials: %d\n', length(trialStart));
clear i experimentType conditions;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Detect photocells per trial.
timeThreshold = 0.28; % sec
firstIndex    = trialStart + 8;
lastIndex     = [trialStart(2:end) - 1; size(consolidated, 1)];
for i = 1:length(trialStart)
    photoEvents = consolidated(firstIndex(i):lastIndex(i), 1);
    if length(photoEvents) < 1
        error('No photoevents!');
    end
    experiment.trial(i).photoevents = photoEvents(1);
    for j = 2:length(photoEvents)
        if photoEvents(j) - experiment.trial(i).photoevents(end) > timeThreshold
            experiment.trial(i).photoevents(end + 1) = photoEvents(j);
        end
    end
    clear photoEvents;
end

clear i j timeThreshold firstIndex lastIndex consolidated;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Only for the search test and the mapping a receptive field test.
if experiment.type == 33 || experiment.type == 34
    
    duration = [];
    for i = 1:length(experiment.trial)
        duration(end + 1) = experiment.trial(i).photoevents(2) - experiment.trial(i).photoevents(1);
    end
    statistics = [min(duration) mean(duration) median(duration) std(duration) max(duration)];
    fprintf('Stimulus offset - Stimulus onset (desired 300 msec):\n');    
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
    figure;
    plot(duration, '-k');
    xlabel('trial no.'), ylabel('Stimulus offset - Stimulus onset, sec');
    title('Stimulus presentation duration');
 
    iti = [];
    for i = 2:length(experiment.trial)
        iti(end + 1) = experiment.trial(i).photoevents(1) - experiment.trial(i - 1).photoevents(2);
    end
    statistics = [min(iti) mean(iti) median(iti) std(iti) max(iti)];
    fprintf('Stimulus onset(Trial #i+1) - Stimulus offset(Trial #i):\n');
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
    figure;
    plot(iti, '-k');
    xlabel('trial no.'), ylabel('Stimulus onset (Trial # i+1) - Stimulus offset (Trial # i), sec');
    title('Inter-trial interval');
    
    delay = [];
    for i = 1:length(experiment.trial)
        delay(end + 1) = experiment.trial(i).photoevents(1) - experiment.trial(i).onset;
    end
    statistics = [min(delay) mean(delay) median(delay) std(delay) max(delay)];
    fprintf('Stimulus onset - Trial onset:\n');
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clutter invariance test. Assuming 15 different conditions (226 stimulus
% presentations). 
nStim = 226;
if experiment.type == 32
    
    for i = 1:length(experiment.trial)
        if length(experiment.trial(i).photoevents) ~= 2 * nStim
            error('Incorrect number of photocell events!');
        end
    end
    
    duration = [];
    for i = 1:length(experiment.trial)
        for j = 1:nStim
            duration(end + 1) = experiment.trial(i).photoevents(2 * j) - experiment.trial(i).photoevents(2 * j - 1);
        end
    end
    statistics = [min(duration) mean(duration) median(duration) std(duration) max(duration)];
    fprintf('Stimulus offset - Stimulus onset (desired 300 msec):\n');    
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
    figure;
    plot(duration, '-k');
    xlabel('stimulus presentation no.'), ylabel('Stimulus offset - Stimulus onset, sec');
    title('Stimulus presentation duration');
    
    isi = [];
    for i = 1:length(experiment.trial)
        for j = 2:nStim
            isi(end + 1) = experiment.trial(i).photoevents(2 * j - 1) - experiment.trial(i).photoevents(2 * j - 2);
        end
    end
    statistics = [min(isi) mean(isi) median(isi) std(isi) max(isi)];
    fprintf('Stimulus #i+1 onset - Stimulus #i offset:\n');
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
    figure;
    plot(isi, '-k');
    xlabel('stimulus presentation no.'), ylabel('Stimulus # i+1 onset - Stimulus # i offset, sec');
    title('Inter-stimulus interval');

    delay = [];
    for i = 1:length(experiment.trial)
        delay(end + 1) = experiment.trial(i).photoevents(1) - experiment.trial(i).onset;
    end
    statistics = [min(delay) mean(delay) median(delay) std(delay) max(delay)];
    fprintf('Stimulus onset - Trial onset:\n');
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);

    ibi = [];
    for i = 2:length(experiment.trial)
        ibi(end + 1) = experiment.trial(i).photoevents(1) - experiment.trial(i - 1).photoevents(end);
    end
    statistics = [min(ibi) mean(ibi) median(ibi) std(ibi) max(ibi)];
    fprintf('First stimulus onset (Block #i+1) - Last stimulus offset (Block #i):\n');
    fprintf('Min - Mean - Median - Std - Max: %.4f - %.4f - %.4f - %.4f - %.4f\n', statistics);
    
end

clear trialStart statistics duration isi iti ibi delay nStim i j;
