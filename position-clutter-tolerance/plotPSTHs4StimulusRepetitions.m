function [glAdapter, glTest] = plotPSTHs4StimulusRepetitions

    load('info.mat');
    rats       = [68481];  %[68547 68430 68481 68474] - V1, [68547 68520 68481] - LI.
    areas      = [2]; % 1 - V1, 2 - LI.
    selection  = used & ismember(info(:, 2), rats) & ismember(info(:, 3), areas);
    sessions   = unique(info(selection, 1));
    nSessions  = length(sessions);
    statistics = examineAdaptation;

    glAdapter  = [];
    glTest     = [];
    
    for counter1 = 1:nSessions
        
        currSession = sessions(counter1);
        load(filenames{currSession});
        disp(filenames{currSession});
        conditions  = find(statistics(:, 1) == currSession & statistics(:, 15) < 0.05);
        conditions  = statistics(conditions, 4);
        nConditions = length(conditions);
        
        if sum(nConditions) == 0
            disp('Discarded');
            continue;
        else
            disp('Analyzed!');
        end
        
        adapterStim = [];
        testStim    = [];
        for counter2 = 1:nConditions
            currCondition = conditions(counter2);
            indices       = find(psths(1:end - 1, 2) == currCondition & psths(2:end, 2) == currCondition & psths(1:end - 1, 1) == psths(2:end, 1));
            adapterStim(end + 1, :) = mean(psths(indices, 3:end));
            testStim(end + 1, :)    = mean(psths(indices + 1, 3:end));
        end
        
        indices  = statistics(:, 1) == currSession;
        if sum(indices) ~= 15
            error('baseline');
        end
        baseline = mean(statistics(indices, 5)); 
        normFactor = max(statistics(indices, 16));
        
        glAdapter(end + 1, :) = (mean(adapterStim) - baseline) / normFactor;
        glTest(end + 1, :)    = (mean(testStim) - baseline) / normFactor;
        
        clear psths spikes;
        
    end
    
    figure;
    plot(mean(glAdapter), '-b', 'LineWidth', 1.5), hold on;
    plot(mean(glTest), '-r', 'LineWidth', 1.5);
    yrange = get(gca, 'YLim');
    xlabel('time, ms'), ylabel('normalized firing rate');
    legend('Adapter', 'Test');
    xlim([1 91]), set(gca, 'XTick', [1 31 61 91]), set(gca, 'XTickLabel', [-300 0 300 600]);
    plot([31 31], yrange, '--k');
    plot([61 61], yrange, '--k');
    
end
