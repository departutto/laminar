%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Last modified on March 31, 2016.
% Copyright by Dzmitry Kaliukhovich.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

psths      = [];
conditions = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binWidth   = 20;                     % msec.
edges      = -before:binWidth:after; % msec.
onsetIndex = (before - binWidth / 2) / binWidth + 1;

for i = 1:length(trial)
    timings             = (trial(i).spikes - trial(i).onset) / 10.0 ^ 3; % msec.
    psths(end + 1, :)   = 10.0 ^ 3 / binWidth * histc(timings, edges);   % Hz.
    conditions(end + 1) = trial(i).condition;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uniqueConditions = unique(conditions);
nConditions      = length(uniqueConditions);
nRows            = 4;
nColumns         = 6;

for i = 1:nConditions
    
    currentCondition = uniqueConditions(i);
    conditionIndices = conditions == currentCondition;
    if mod(i, nRows * nColumns) == 1
        figure;
        currentSubplot = 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(nRows, nColumns, currentSubplot), plot(mean(psths(conditionIndices, :)));
    xlim([1 size(psths, 2)]);
    hold on, plot([onsetIndex size(psths, 2)], [0 0], '-r', 'LineWidth', 2);
    set(gca, 'XTick',      [1 onsetIndex size(psths, 2)]);
    set(gca, 'XTickLabel', [-before 0 after]);
    xlabel('time, msec'), ylabel('firing rate, Hz');
    title(['Condition #' num2str(currentCondition) ', ' num2str(sum(conditionIndices)) ' trials']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    currentSubplot = currentSubplot + 1;

end
