%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Align/synchronize spike timestamps and behavioral data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fileName, pathName] = uigetfile('*.nev', 'Select Events file (*.nev)');
if ~fileName
    error('Failed to open Events file!');
else    
    fprintf('Events file: %s%s\n', pathName, fileName);
    timeStamps = Nlx2MatEV([pathName fileName], [1 0 0 0 0], 0, 1, 1);    
end

if exist('selectedSpikeTimestampsInUsec', 'var') || exist('experiment', 'var')
    selectedSpikeTimestampsInSec = (selectedSpikeTimestampsInUsec - timeStamps(1)) / 10 ^ 6;
else
    error('One of the required variables has not been uploaded in the Matlab workspace!');    
end

clear fileName pathName timeStamps;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute PSTH per stimulus presentation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

psths    = [];
nStim    = 226;
preStim  = -0.305;
stimDur  = 0.300;
postStim = stimDur + 0.305;
step     = 0.010;
bins     = preStim:step:postStim;

for i = 1:length(experiment.trial)
    fprintf('Trial #%02d: Stimulus #', i);
    for j = 1:nStim
        fprintf('%03d', j);
        tmpBins = bins + experiment.trial(i).photoevents(2 * j - 1);
        tmpArr  = [];
        for k = 2:length(tmpBins)
            tmpArr(end + 1) = sum(selectedSpikeTimestampsInSec >= tmpBins(k - 1) & selectedSpikeTimestampsInSec < tmpBins(k)) / step;
        end
        psths(end + 1, :) = [i experiment.trial(i).condition(j) tmpArr];
        if j ~= nStim
            fprintf('\b\b\b');
        end
    end
    fprintf('\n');
end

clear i j k nStim preStim stimDur postStim step bins tmpBins tmpArr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot average PSTHs per stimulus condition.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rows     = 3;
columns  = 5;

ntrials  = zeros(1, rows * columns);
tmppsths = zeros(rows * columns, size(psths, 2) - 2); 

for i = 1:rows * columns
    indices        = psths(:, 2) == i;
    ntrials(i)     = sum(indices);
    tmppsths(i, :) = mean(psths(indices, 3:end));    
end

% Baseline correction: time window of [-95; 5) ms relative to stimulus onset.
tmppsths   = tmppsths - mean(mean(psths(:, 24:33), 2));

ystep   = 50;
ymax    = max(max(tmppsths));
ymax    = ymax + ystep - mod(ymax, 50);
ymin    = -25;

xticks  = [1 31 61 91];
xlabels = {'-300', '0', '300', '600'}; 

figure; 
for i = 1:rows * columns
    subplot(rows, columns, i), plot(tmppsths(i, :), '-k');
    xlim([1 size(psths, 2) - 2]), ylim([ymin ymax]);
    set(gca, 'XTick', xticks), set(gca, 'XTickLabel', xlabels);
    set(gca, 'YTick', [ymin 0:ystep:ymax]);
    hold on;
    plot([xticks(2) xticks(2)], [ymin ymax], '-r');
    plot([xticks(3) xticks(3)], [ymin ymax], '-r');
    title(['Cond #' num2str(i) ': ' num2str(ntrials(i)) ' presentations']);
end

clear rows columns ntrials tmppsths indices ntrials i ystep ymax ymin xticks xlabels;
