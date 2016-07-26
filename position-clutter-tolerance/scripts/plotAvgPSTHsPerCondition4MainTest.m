 [fileName, dirName] = uigetfile('*.mat', 'Select .mat file with PSTHs per stimulus presentation', 'MultiSelect', 'off');
 
 if isnumeric(fileName)
    error('No file with PSTHs per stimulus presentation has been selected!');
 end
 
 avgPSTH = zeros(2260, 93);
 
 try
     load([dirName fileName]);
     descriptors = {};
     for counter = 1:length(clusterIds)
         descriptors{end + 1} = sprintf('%d (%d spikes)', clusterIds(counter), nSpikes(counter));
     end
     [indices, ok] = listdlg('Name', 'Select clusters to analyze', 'SelectionMode', 'multiple', 'ListString', descriptors);
     if ok == 0
         return;
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     selectedClusters = clusterIds(indices);
     nSelectedSpikes  = sum(nSpikes(indices));
     disp(['Selected clusters: ' mat2str(selectedClusters)]);
     disp(['Number of spikes:  ' num2str(nSelectedSpikes)]);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     for counter = 1:length(indices)
         currentIndex      = indices(counter);
         avgPSTH(:, 3:end) = avgPSTH(:, 3:end) + psths{currentIndex}(:, 3:end);
     end
     avgPSTH(:, 1:2) = psths{end}(:, 1:2); % Block no. x Condition no.
 catch err
     error('Failed to upload the required data into the Matlab workspace!');
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 nRows = 3;
 nCols = 5;
 figure;
 
 for counter = 1:(nRows * nCols)
    indices = avgPSTH(:, 2) == counter;
    subplot(nRows, nCols, counter), plot(mean(avgPSTH(indices, 3:end)), '-b'), hold on;
    xlim([1 91]), set(gca, 'XTick', [1 31 61 91]), set(gca, 'XTickLabel', -300:300:600);
    plot([31 31], get(gca, 'YLim'), '--k');
    plot([61 61], get(gca, 'YLim'), '--k');
    xlabel('time, ms'), ylabel('firing rate, spikes/sec');
    title(['Cond #' num2str(counter) ': ' num2str(sum(indices)) ' presentations']);
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 figure;
 plot(mean(avgPSTH(:, 3:end)), '-b'), hold on;
 xlim([1 91]), set(gca, 'XTick', [1 31 61 91]), set(gca, 'XTickLabel', -300:300:600);
 plot([31 31], get(gca, 'YLim'), '--k');
 plot([61 61], get(gca, 'YLim'), '--k');
 xlabel('time, ms'), ylabel('firing rate, spikes/sec');
 title('Pooling across selected conditions');
 
 clear descriptors counter indices ok currentIndex nRows nCols;
 