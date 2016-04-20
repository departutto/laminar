function statistics = examineAdaptation

    clc, load('info.mat');
    selection      = used & (info(:, 3) == 1 | info(:, 3) == 2); % V1 or LI
    sessionNames   = filenames(selection);
    ratIdentifiers = info(selection, 2);
    brainAreas     = info(selection, 3);
    statistics     = collectResponses(sessionNames, ratIdentifiers, brainAreas);
    statistics     = baselineCorrection(statistics);
    statistics     = responseNormalization(statistics);

    showNumberOfAnalyzedSites(statistics);
    showResponsesInRepetitionTrials(statistics, [68547 68430 68481 68474], 1);    % V1 
    showResponsesInRepetitionTrials(statistics, [68547 68520 68481], 2);          % LI       
    
    showHistogramsForRepetitionTrials(statistics, [68547 68430 68481 68474], 1);  % V1
    showHistogramsForRepetitionTrials(statistics, [68547 68520 68481], 2);        % LI

    showHistogramsForRepetitionTrials(statistics, 68547, 1);                      % V1
    showHistogramsForRepetitionTrials(statistics, 68430, 1);                      % V1
    showHistogramsForRepetitionTrials(statistics, 68481, 1);                      % V1
    showHistogramsForRepetitionTrials(statistics, 68474, 1);                      % V1
    
    showHistogramsForRepetitionTrials(statistics, 68547, 2);                      % LI
    showHistogramsForRepetitionTrials(statistics, 68520, 2);                      % LI
    showHistogramsForRepetitionTrials(statistics, 68481, 2);                      % LI
    
    assessResponseModulationByStimulusRepetition(statistics, 68547, 1);           % V1
    assessResponseModulationByStimulusRepetition(statistics, 68430, 1);           % V1
    assessResponseModulationByStimulusRepetition(statistics, 68481, 1);           % V1
    assessResponseModulationByStimulusRepetition(statistics, 68474, 1);           % V1
   
    assessResponseModulationByStimulusRepetition(statistics, 68547, 2);           % LI
    assessResponseModulationByStimulusRepetition(statistics, 68520, 2);           % LI
    assessResponseModulationByStimulusRepetition(statistics, 68481, 2);           % LI
    
end

function statistics = collectResponses(sessionNames, ratIdentifiers, brainAreas)

    statistics = [];
    
    % Number of blocks in one complete recordings session.
    nBlocks = 10;
    
    % Number of stimulus presentations in one complete block.
    nStim = 226;
    
    % Number of stimulus presentations in one complete recordings session.
    nTotal = nBlocks * nStim;    
    
    % Number of recordings sessions to analyze.
    nSessions  = length(sessionNames);
    
    % Number of different stimulus conditions.
    nConditions = 15;
    
    for currSession = 1:nSessions
        fprintf('%03d: %s\n', currSession, sessionNames{currSession});
        load(sessionNames{currSession});
        
        % Session identifier (in numeric form).
        sessionIdentifier = str2num(sessionNames{currSession}(1:3));
        
        % Compute baseline activity and response per stimulus presentation.
        baseline  = mean(psths(:, 24:33), 2);  % [-95; 5) ms
        fullResp  = mean(psths(:, 36:65), 2);  % [25; 325) ms
        earlyResp = mean(psths(:, 36:50), 2);  % [25; 175) ms
        lateResp  = mean(psths(:, 51:65), 2);  % [175; 325) ms
        
        temporary = [];
        for currCondition = 1:nConditions
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Select all presentations of a specified stimulus condition.
            conditionIndices = find(psths(:, 2) == currCondition);
            
            % Indices of the adapter and test stimuli in repetition trials.
            adapterStimulus = find(psths(1:end - 1, 1) == psths(2:end, 1) & ...
                                   psths(1:end - 1, 2) == psths(2:end, 2) & ...
                                   psths(1:end - 1, 2) == currCondition);
            testStimulus    = adapterStimulus + 1;
            if length(adapterStimulus) ~= nBlocks
                error('Incorrect number of stimulus repetitions per condition!');
            end
            
            % Remove the first stimulus presentation at the beginning of each block.
            conditionIndices = setdiff(conditionIndices, 1:nStim:nTotal);
            if length(conditionIndices) ~= nBlocks * nConditions
                error('Incorrect number of analyzed stimulus presentations per condition!');
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            temporary(end + 1, :) = [sessionIdentifier                 ...
                                     ratIdentifiers(currSession)       ...
                                     brainAreas(currSession)           ...
                                     currCondition                     ...
                                     mean(baseline(conditionIndices))  ... 
                                     mean(fullResp(conditionIndices))  ...
                                     mean(earlyResp(conditionIndices)) ...
                                     mean(lateResp(conditionIndices))  ...
                                     mean(fullResp(adapterStimulus))   ... 
                                     mean(fullResp(testStimulus))      ...
                                     mean(earlyResp(adapterStimulus))  ...
                                     mean(earlyResp(testStimulus))     ...
                                     mean(lateResp(adapterStimulus))   ...
                                     mean(lateResp(testStimulus))      ...
                                     signrank(baseline(conditionIndices), fullResp(conditionIndices), 'tail', 'left')];
        end       
        statistics = [statistics; temporary];
        
        clear spikes psths temporary;    
    end

end

function updatedStatistics = baselineCorrection(statistics)

    % Copy responses for the baseline correction.
    netResponses = statistics(:, 6:14);
    
    % Session identifiers (in numeric form).
    sessionIdentifiers = unique(statistics(:, 1));
    
    % Number of recordings sessions to analyze.
    nSessions = length(sessionIdentifiers);
    
    % Number of different stimulus conditions.
    nConditions = 15;
    
    for index = 1:nSessions
        currSession = sessionIdentifiers(index);
        indices     = statistics(:, 1) == currSession;
        if sum(indices) ~= nConditions
            error('Incorrect number of stimulus conditions per recordings session!');
        end
        % Baseline correction. 
        baseline                 = mean(statistics(indices, 5));  % [-95; 5) ms
        netResponses(indices, :) = netResponses(indices, :) - baseline;
    end

    updatedStatistics = [statistics netResponses];
    
end

function updatedStatistics = responseNormalization(statistics)

    % Copy responses for normalization.
    normalized = statistics(:, 16:24);
    
    % Session identifiers (in numeric form).
    sessionIdentifiers = unique(statistics(:, 1));
    
    % Number of recordings sessions to analyze.
    nSessions = length(sessionIdentifiers);
    
    % Number of different stimulus conditions.
    nConditions = 15;
    
    for index = 1:nSessions
        currSession = sessionIdentifiers(index);
        indices     = statistics(:, 1) == currSession;
        if sum(indices) ~= nConditions
            error('Incorrect number of stimulus conditions per recordings session!');
        end
        % Response normalization.
        normalizationFactor    = max(statistics(indices, 16));  % net response within a window of [25; 325) ms
        normalized(indices, :) = normalized(indices, :) / normalizationFactor;
    end
    
    updatedStatistics = [statistics normalized];
    
end

function showNumberOfAnalyzedSites(statistics)
    
    ratIdentifiers  = unique(statistics(:, 2));
    nRats           = length(ratIdentifiers);
    
    % Only significant excitatory response in the full analysis window.
    significantResp = statistics(:, 15) < 0.05 & statistics(:, 16) > 0;
    statistics      = statistics(significantResp, :);
    
    areaLabels      = {'V1', 'LI', 'TO', 'UNKNOWN'};
    nBrainAreas     = length(areaLabels);
    
    disp('---------------------------------------------------------------------');
    for rat = 1:nRats
        currentRat  = ratIdentifiers(rat);
        for area = 1:nBrainAreas
            currentSelection = statistics(:, 2) == currentRat & statistics(:, 3) == area;
            siteIdentifiers  = unique(statistics(currentSelection, 1));
            nSites           = length(siteIdentifiers);
            if nSites
                fprintf('Rat = %5d, Brain area = %s, N(sites) = %d\n', currentRat, areaLabels{area}, nSites);
            end
        end
    end
    
end

function showResponsesInRepetitionTrials(statistics, rats, brainArea)

    areaLabels = {'V1', 'LI', 'TO', 'UNKNOWN'};
    colors     = ['b' 'g' 'r' 'k' 'm' 'c' 'y'];
    range      = [-1 3];
    ticks      = -1:1:3;
    tickLabels = {'-1<=', '0', '1', '2', '>=3'};
    
    if length(rats) > length(colors)
        warn('Not enough colors to paint the data points of different rats!');
        return;
    end  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for column = 30:33
        indicesLower = statistics(:, column) < range(1);
        indicesUpper = statistics(:, column) > range(2);
        statistics(indicesLower, column) = range(1);
        statistics(indicesUpper, column) = range(2);        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure;
    
    for counter = 1:length(rats)
        
        % Rat identifier.
        ratId          = rats(counter);       
        
        % Only significant excitatory response in the full analysis window.
        selectionAll   = statistics(:, 2) == ratId & statistics(:, 3) == brainArea & statistics(:, 15) < 0.05 & statistics(:, 16) > 0;
        nAll           = sum(selectionAll);
        
        % Analyzed stimulus conditions x multi-unit sites in both time windows.
        selectionEarly = selectionAll & ~(statistics(:, 30) < 0 & statistics(:, 31) < 0);
        selectionLate  = selectionAll & ~(statistics(:, 32) < 0 & statistics(:, 33) < 0);
        nEarly         = sum(selectionEarly);
        nLate          = sum(selectionLate);
        
        disp('---------------------------------------------------------------------');
        disp(['Rat(s) = ' mat2str(ratId) ', Brain area = ' areaLabels{brainArea}]);
        disp(['N(stimulus condition x multi-unit site combinations):']);
        disp(['Irrespective of the analysis window: N = ' num2str(nAll)]);
        disp(['Early analysis window of 25-175 ms: N = '  num2str(nEarly)]);
        disp(['Late analysis window of 175-325 ms: N = '  num2str(nLate)]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Presentations of single stimuli.
        singleEarly    = selectionEarly & ismember(statistics(:, 4), 1:6);
        singleLate     = selectionLate  & ismember(statistics(:, 4), 1:6);
        
        % Presentations of two different stimuli.
        differentEarly = selectionEarly & ismember(statistics(:, 4), 7:12);
        differentLate  = selectionLate  & ismember(statistics(:, 4), 7:12);
        
        % Presentations of two identical stimuli.
        identicalEarly = selectionEarly & ismember(statistics(:, 4), 13:15);
        identicalLate  = selectionLate  & ismember(statistics(:, 4), 13:15);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        subplot(1, 2, 1), plot(statistics(singleEarly, 30),    statistics(singleEarly, 31),    ['*' colors(counter)], 'MarkerSize', 3), hold on;
        subplot(1, 2, 1), plot(statistics(differentEarly, 30), statistics(differentEarly, 31), ['+' colors(counter)], 'MarkerSize', 3);
        subplot(1, 2, 1), plot(statistics(identicalEarly, 30), statistics(identicalEarly, 31), ['o' colors(counter)], 'MarkerSize', 2);
        plot(range, [0 0], '--k'), plot([0 0], range, '--k'), plot(range, range, '--k');
        xlim(range), set(gca, 'XTick', ticks), set(gca, 'XTickLabel', tickLabels); 
        ylim(range), set(gca, 'YTick', ticks), set(gca, 'YTickLabel', tickLabels);
        xlabel('normalized net response to adapter'), ylabel('normalized net response to test');
        title([areaLabels{brainArea} ': Early analysis window of 25-175 ms']);
        
        subplot(1, 2, 2), plot(statistics(singleLate, 32),    statistics(singleLate, 33),    ['*' colors(counter)], 'MarkerSize', 3), hold on;
        subplot(1, 2, 2), plot(statistics(differentLate, 32), statistics(differentLate, 33), ['+' colors(counter)], 'MarkerSize', 3);
        subplot(1, 2, 2), plot(statistics(identicalLate, 32), statistics(identicalLate, 33), ['o' colors(counter)], 'MarkerSize', 2);
        plot(range, [0 0], '--k'), plot([0 0], range, '--k'), plot(range, range, '--k');
        xlim(range), set(gca, 'XTick', ticks), set(gca, 'XTickLabel', tickLabels); 
        ylim(range), set(gca, 'YTick', ticks), set(gca, 'YTickLabel', tickLabels);
        xlabel('normalized net response to adapter'), ylabel('normalized ned response to test');
        title([areaLabels{brainArea} ': Late analysis window of 175-325 ms']);
        
    end
    
end

function showHistogramsForRepetitionTrials(statistics, rats, brainArea)   
  
    areaLabels       = {'V1', 'LI', 'TO', 'UNKNOWN'};
    
    % Only significant excitatory response in the full analysis window.
    selectionAll     = ismember(statistics(:, 2), rats) & statistics(:, 3) == brainArea & statistics(:, 15) < 0.05 & statistics(:, 16) > 0;
    selectionEarly   = selectionAll & ~(statistics(:, 30) < 0 & statistics(:, 31) < 0);
    selectionLate    = selectionAll & ~(statistics(:, 32) < 0 & statistics(:, 33) < 0);
  
    nAll             = sum(selectionAll);
    nEarly           = sum(selectionEarly);
    nLate            = sum(selectionLate);
    
	adapterStimEarly = statistics(selectionEarly, 30);
    testStimEarly    = statistics(selectionEarly, 31);    
    adapterStimLate  = statistics(selectionLate, 32);
    testStimLate     = statistics(selectionLate, 33);
    
    disp('---------------------------------------------------------------------');
    disp(['Rat(s) = ' mat2str(rats) ', Brain area = ' areaLabels{brainArea}]);
	disp(['N(stimulus condition x multi-unit site combinations) = ' num2str(nAll)]);
    disp('Early analysis window of 25-175 ms:');
    disp(['N(stimulus condition x multi-unit site combinations) = ' num2str(nEarly)]);
    disp(['Response(adapter): Mean x Median = ' num2str(mean(adapterStimEarly)) ' x ' num2str(median(adapterStimEarly))]);
    disp(['Response(test): Mean x Median = '    num2str(mean(testStimEarly))    ' x ' num2str(median(testStimEarly))]);
    disp('Late analysis window of 175-325 ms:');
    disp(['N(stimulus condition x multi-unit site combinations) = ' num2str(nLate)]);
    disp(['Response(adapter): Mean x Median = ' num2str(mean(adapterStimLate)) ' x ' num2str(median(adapterStimLate))]);
    disp(['Response(test): Mean x Median = '    num2str(mean(testStimLate))    ' x ' num2str(median(testStimLate))]);    
    
    showHistogram(adapterStimEarly, testStimEarly, [-1 3], 0.2, [areaLabels{brainArea} ': Early analysis window of 25-175 ms']);
    showHistogram(adapterStimLate,  testStimLate,  [-1 3], 0.2, [areaLabels{brainArea} ': Late analysis window of 175-325 ms']);
    
end

function showHistogram(adapterStim, testStim, xrange, step, strTitle)

    bins = [];
    for lowerBoundary = xrange(1):step:xrange(2)
        upperBoundary = lowerBoundary + step;
        observations  = lowerBoundary <= adapterStim & adapterStim < upperBoundary;
        suppression   = adapterStim(observations) > testStim(observations);
        bins(end + 1) = sum(suppression) / sum(observations) * 100.0;
    end
   
    yrange = [0.0 100.0];
    chance = 50.0;
    
    figure;
    id = bar(xrange(1):step:xrange(2), bins, 'histc');
    hold on, plot(xrange, [chance chance], '--r');  
    plot([mean(adapterStim)   mean(adapterStim)],   [0 100], '-m');
    plot([mean(testStim)      mean(testStim)],      [0 100], '-c');
    plot([median(adapterStim) median(adapterStim)], [0 100], '--m');
    plot([median(testStim)    median(testStim)],    [0 100], '--c');
    set(id, 'FaceColor', [0.7 0.7 0.7]);
    xlim(xrange), xlabel('normalized net response to adapter');
    ylim(yrange), ylabel('% response suppression');
    title(strTitle);
    
end

function showStatisticsOnResponseModulation(coeffs, ratIdentifier, brainArea, description)

    areaLabels  = {'V1', 'LI', 'TO', 'UNKNOWN'};
    nDataPoints = sum(~isnan(coeffs));
    
    singleStimuli = coeffs(~isnan(coeffs(:, 1)), 1);
    twoDifferent  = coeffs(~isnan(coeffs(:, 2)), 2);
    twoIdentical  = coeffs(~isnan(coeffs(:, 3)), 3);
    allTogether   = coeffs(~isnan(coeffs(:, 4)), 4);
    
    disp('---------------------------------------------------------------------');
    disp(['Description: ' description]);
    disp(['Rat = ' num2str(ratIdentifier) ', Brain area = ' areaLabels{brainArea}]);
    
    disp(['Number of analyzed multi-unit sites: ']);
    disp(['N(single stimuli) = '          num2str(length(singleStimuli))]);
    disp(['N(two different stimuli) = '   num2str(length(twoDifferent))]);
    disp(['N(two identical stimuli) = '   num2str(length(twoIdentical))]);
    disp(['N(all conditions together) = ' num2str(length(allTogether))]);
    
    disp(['Mean percent response suppression: ']);
    disp(['% suppression(single stimuli) = '          num2str(mean(singleStimuli))]);
    disp(['% suppression(two different stimuli) = '   num2str(mean(twoDifferent))]);
    disp(['% suppression(two identical stimuli) = '   num2str(mean(twoIdentical))]);
    disp(['% suppression(all conditions together) = ' num2str(mean(allTogether))]);
    
    disp(['p-values as tested against 50.0%: ']);
    disp(['% suppression(single stimuli) = '          num2str(signrank(singleStimuli, 50.0))]);
    disp(['% suppression(two different stimuli) = '   num2str(signrank(twoDifferent,  50.0))]);
    disp(['% suppression(two identical stimuli) = '   num2str(signrank(twoIdentical,  50.0))]);
    disp(['% suppression(all conditions together) = ' num2str(signrank(allTogether,   50.0))]);
    
end

function [earlyCoeffs, lateCoeffs] = assessResponseModulationByStimulusRepetition(statistics, ratIdentifier, brainArea) 
    
    % Only significant excitatory response in the full analysis window.
    selectionAll   = statistics(:, 2) == ratIdentifier & statistics(:, 3) == brainArea & statistics(:, 15) < 0.05 & statistics(:, 16) > 0;
    selectionEarly = selectionAll & ~(statistics(:, 30) < 0 & statistics(:, 31) < 0);
    selectionLate  = selectionAll & ~(statistics(:, 32) < 0 & statistics(:, 33) < 0);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sitesEarly  = unique(statistics(selectionEarly, 1));
    earlyCoeffs = [];
    for counter = 1:length(sitesEarly)
        currSelection = statistics(:, 1) == sitesEarly(counter) & selectionEarly;
        conditions    = statistics(currSelection, 4);
        % Normalized net responses to the adapter and test stimuli in repetition trials.
        adapterStim   = statistics(currSelection, 30);
        testStim      = statistics(currSelection, 31);
        % Different selections of stimulus conditions.
        singleStimuli = ismember(conditions, 1:6);
        twoDifferent  = ismember(conditions, 7:12);
        twoIdentical  = ismember(conditions, 13:15);
        nPoints       = [sum(singleStimuli) sum(twoDifferent) sum(twoIdentical) sum(currSelection)];
        % Number of stimulus conditions showing response suppression.
        nSuppression  = [sum(adapterStim(singleStimuli) > testStim(singleStimuli)) ...
                         sum(adapterStim(twoDifferent)  > testStim(twoDifferent))  ...
                         sum(adapterStim(twoIdentical)  > testStim(twoIdentical))  ...
                         sum(adapterStim > testStim)];
        earlyCoeffs(end + 1, :) = 100.0 * nSuppression ./ nPoints;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sitesLate  = unique(statistics(selectionLate, 1));
    lateCoeffs = [];
    for counter = 1:length(sitesLate)
        currSelection = statistics(:, 1) == sitesLate(counter) & selectionLate;
        conditions    = statistics(currSelection, 4);
        % Normalized net responses to the adapter and test stimuli in repetition trials.
        adapterStim   = statistics(currSelection, 32);
        testStim      = statistics(currSelection, 33);
        % Different selections of stimulus conditions.
        singleStimuli = ismember(conditions, 1:6);
        twoDifferent  = ismember(conditions, 7:12);
        twoIdentical  = ismember(conditions, 13:15);
        nPoints       = [sum(singleStimuli) sum(twoDifferent) sum(twoIdentical) sum(currSelection)];
        % Number of stimulus conditions showing response suppression.
        nSuppression  = [sum(adapterStim(singleStimuli) > testStim(singleStimuli)) ...
                         sum(adapterStim(twoDifferent)  > testStim(twoDifferent))  ...
                         sum(adapterStim(twoIdentical)  > testStim(twoIdentical))  ...
                         sum(adapterStim > testStim)];
        lateCoeffs(end + 1, :) = 100.0 * nSuppression ./ nPoints;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    showStatisticsOnResponseModulation(earlyCoeffs, ratIdentifier, brainArea, 'Early time window of 25-175 ms');
    showStatisticsOnResponseModulation(lateCoeffs,  ratIdentifier, brainArea, 'Late time window of 175-325 ms');
    
end
