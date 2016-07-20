nClusters = length(psths);
avgPSTH   = zeros(1, 91);

for counter = 1:nClusters
    avgPSTH = avgPSTH + mean(psths{counter}(:, 3:93));
end
avgPSTH = avgPSTH / nClusters;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xticks  = [1 31 61 91];
xlabels = {'-300', '0', '300', '600'}; 

figure;
plot(avgPSTH, '-b', 'LineWidth', 2), hold on;
xlim([xticks(1) xticks(end)]);
plot([xticks(2) xticks(2)], get(gca, 'YLim'), '--k');
plot([xticks(3) xticks(3)], get(gca, 'YLim'), '--k');
set(gca, 'XTick', xticks), set(gca, 'XTickLabel', xlabels);
xlabel('time, msec'), ylabel('firing rate, spikes/sec');
title(['Pooling across all spikes (' num2str(nClusters) ' clusters, ' num2str(sum(nSpikes)) ' spikes)']);     
