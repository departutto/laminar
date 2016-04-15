function aggregatedPSTHs = selectMUASitesAndProduceAveragePSTHs(ratId, brainArea)
    
    % Select analyzed MUA sites.
    load('info.mat');
    selectedRatAndArea = used & info(:, 2) == ratId & info(:, 3) == brainArea;
    selectedFileNames  = filenames(selectedRatAndArea);
    nSelectedFileNames = length(selectedFileNames);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Number of blocks in one complete recordings session.
    nBlocks = 10;
    
    % Number of stimulus presentations in one complete block.
    nStim = 226;
    
    % Number of stimulus presentations in one complete recordings session.
    nTotal = nBlocks * nStim;
    
    % Indices of stimulus presentations to analyze, excluding the first 
    % presentation at the beginning of each block.
    indices = setdiff(1:nTotal, 1:nStim:nTotal);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Single stimuli x Two different stimuli x Two identical stimuli.
    aggregatedPSTHs = {[] [] []};
    
    for currFileIndex = 1:nSelectedFileNames
        
        currFileName = selectedFileNames{currFileIndex}; 
        disp(currFileName);
        load(currFileName);        
        
        grossPSTHsPerStim = psths(indices, :);
        statistics        = collectStatistics(grossPSTHsPerStim);
        grossAveragePSTHs = getGrossAveragePSTHs(grossPSTHsPerStim);
        baselineActivity  = mean(statistics(:, 1));        
        netAveragePSTHs   = grossAveragePSTHs - baselineActivity;

        % Response normalization.
        netResponses      = statistics(:, 2) - baselineActivity;
        normFactor        = max(netResponses);
        netAveragePSTHs   = netAveragePSTHs / normFactor;
        
        singleStimuliSel  = logical([1 1 1 1 1 1 0 0 0 0 0 0 0 0 0]);        
        twoDifferentSel   = logical([0 0 0 0 0 0 1 1 1 1 1 1 0 0 0]);        
        twoIdenticalSel   = logical([0 0 0 0 0 0 0 0 0 0 0 0 1 1 1]);
        
        singleStimuliPSTH = averagePSTHForSelection(netAveragePSTHs, singleStimuliSel, statistics);
        twoDifferentPSTH  = averagePSTHForSelection(netAveragePSTHs, twoDifferentSel, statistics); 
        twoIdenticalPSTH  = averagePSTHForSelection(netAveragePSTHs, twoIdenticalSel, statistics);
        
        if ~isempty(singleStimuliPSTH)
            aggregatedPSTHs{1}(end + 1, :) = singleStimuliPSTH;
        end
        
        if ~isempty(twoDifferentPSTH)
            aggregatedPSTHs{2}(end + 1, :) = twoDifferentPSTH;
        end
        
        if ~isempty(twoIdenticalPSTH)
            aggregatedPSTHs{3}(end + 1, :) = twoIdenticalPSTH;
        end
        
        clear psths spikes;
        
    end
    
    plotPSTHs(aggregatedPSTHs);

end

function grossAveragePSTHs = getGrossAveragePSTHs(psths)

    grossAveragePSTHs = [];
    
    % Number of different stimulus conditions.
    nConditions = 15;
    
    % Number of analyzed stimulus presentations per condition.
    nPresentations = 150;
    
    for currCondition = 1:nConditions
        
        indices = psths(:, 2) == currCondition;
        if sum(indices) ~= nPresentations
            error('Incorrect number of analyzed stimulus presentations per condition!');
        end

        grossAveragePSTHs(end + 1, :) = mean(psths(indices, 3:end));
        
    end
    
end

function statistics = collectStatistics(psths)

    statistics = [];
    
    % Number of different stimulus conditions.
    nConditions = 15;
    
    % Number of analyzed stimulus presentations per condition.
    nPresentations = 150;
    
    % Compute baseline activity and response per stimulus presentation.
    baseline = mean(psths(:, 24:33), 2);  % [-95; 5) ms
    response = mean(psths(:, 36:65), 2);  % [25; 325) ms
        
    for currCondition = 1:nConditions
        
        indices = psths(:, 2) == currCondition;
        if sum(indices) ~= nPresentations
            error('Incorrect number of analyzed stimulus presentations per condition!');
        end
        
        meanBaseline = mean(baseline(indices));
        meanResponse = mean(response(indices));
        
        % One-sided Wilcoxon matched pairs test.
        pvalue = signrank(baseline(indices), response(indices), 'tail', 'left');
        
        statistics(end + 1, :) = [meanBaseline meanResponse pvalue];
        
    end

end

function averagePSTH = averagePSTHForSelection(netAveragePSTHs, conditions, statistics)

    selection     = conditions' & statistics(:, 3) < 0.05;
    selectedPSTHs = netAveragePSTHs(selection, :);
    
    if isempty(selectedPSTHs)
        averagePSTH = [];
    end

    if size(selectedPSTHs, 1) == 1
        averagePSTH = selectedPSTHs;
    end
    
    if size(selectedPSTHs, 1) > 1
        averagePSTH = mean(selectedPSTHs);
    end
    
end

function plotPSTHs(aggregatedPSTHs)

    thickness = 1.5;
    
    % Number of analyzed multi-unit sites.
    nSingleStimuli = size(aggregatedPSTHs{1}, 1);
    nTwoDifferent  = size(aggregatedPSTHs{2}, 1);
    nTwoIdentical  = size(aggregatedPSTHs{3}, 1);
    nAnalyzedSites = [nSingleStimuli nTwoDifferent nTwoIdentical];
    
    figure;
    plot(mean(aggregatedPSTHs{1}), '-r', 'LineWidth', thickness), hold on;
    plot(mean(aggregatedPSTHs{2}), '-b', 'LineWidth', thickness);
    plot(mean(aggregatedPSTHs{3}), '-g', 'LineWidth', thickness);
    legend('Single', 'Two different', 'Two identical', 'Location', 'NorthEast');
    xlabel('time, ms'), ylabel('normalized response');
    title(['Number of analyzed sites = ' mat2str(nAnalyzedSites)]);
    
    yrange = get(gca, 'YLim');
    
    xlim([1 91]), set(gca, 'XTick', [1 31 61 91]), set(gca, 'XTickLabel', [-300 0 300 600]);
    plot([31 31], yrange, '--k');
    plot([61 61], yrange, '--k');
    
    % Baseline of [-95; 5) ms relative to stimulus onset.
    plot([21.5 31.5], [yrange(1) yrange(1)], '-k', 'LineWidth', thickness);
    % Time window of [25; 175) ms relative to stimulus onset.
    plot([33.5 48.5], [yrange(1) yrange(1)], '-m', 'LineWidth', thickness);
    % Time window of [175; 325) ms relative to stimulus onset.
    plot([48.5 63.5], [yrange(1) yrange(1)], '-c', 'LineWidth', thickness);
    
end
