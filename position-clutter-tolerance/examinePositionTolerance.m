function responses = examinePositionTolerance(statistics)

    analysisWindow = 'late';  % early | late | full
    selectionRule  = @selectionRule5;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clc, load('info.mat');
    selection      = used & (info(:, 3) == 1 | info(:, 3) == 2); % V1 or LI
    sessionNames   = filenames(selection);
    ratIdentifiers = info(selection, 2);
    brainAreas     = info(selection, 3);
    responses      = collectResponses(sessionNames, ratIdentifiers, brainAreas);
    responses      = baselineCorrection(statistics, responses);
    responses      = responseNormalization(statistics, responses); 
    responses      = selectAnalysisWindow(analysisWindow, statistics, responses); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Examine position tolerance in V1 in each rat separately.
    positionTolerance(responses, 68430, 1, selectionRule);
    positionTolerance(responses, 68474, 1, selectionRule);
    positionTolerance(responses, 68481, 1, selectionRule);
    positionTolerance(responses, 68547, 1, selectionRule);
    
    % Examine position tolerance in LI in each rat separately.
    positionTolerance(responses, 68520, 2, selectionRule);
    positionTolerance(responses, 68481, 2, selectionRule);
    positionTolerance(responses, 68547, 2, selectionRule);
    
end

function responses = collectResponses(sessionNames, ratIdentifiers, brainAreas)

    responses = [];
    
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
        fullResp  = mean(psths(:, 36:65), 2);  % [25; 325) ms
        earlyResp = mean(psths(:, 36:50), 2);  % [25; 175) ms
        lateResp  = mean(psths(:, 51:65), 2);  % [175; 325) ms
        
        temporary = [];
        for currCondition = 1:nConditions
            
            % Select all presentations of a specified stimulus condition.
            conditionIndices = find(psths(:, 2) == currCondition);
            
            % Remove the first stimulus presentation at the beginning of each block.
            conditionIndices = setdiff(conditionIndices, 1:nStim:nTotal);
            if length(conditionIndices) ~= nBlocks * nConditions
                error('Incorrect number of analyzed stimulus presentations per condition!');
            end
            
            % Indices of odd and even stimulus presentations.
            oddPresentations  = conditionIndices(1:2:(nBlocks * nConditions));
            evenPresentations = conditionIndices(2:2:(nBlocks * nConditions));
            
            temporary(end + 1, :) = [sessionIdentifier                  ...
                                     ratIdentifiers(currSession)        ...
                                     brainAreas(currSession)            ...
                                     currCondition                      ...
                                     mean(fullResp(oddPresentations))   ...
                                     mean(fullResp(evenPresentations))  ...
                                     mean(earlyResp(oddPresentations))  ...
                                     mean(earlyResp(evenPresentations)) ...
                                     mean(lateResp(oddPresentations))   ...
                                     mean(lateResp(evenPresentations))];
                                     
        end    
        responses = [responses; temporary];
        
        clear spikes psths temporary;
        
    end
    
end

function updatedResponses = baselineCorrection(statistics, responses)

    % Copy responses for the baseline correction.
    netResponses    = responses(:, 5:10);
    
    % Site identifiers and their number.
    siteIdentifiers = unique(responses(:, 1));
    nSites          = length(siteIdentifiers);
    
    % Number of different stimulus conditions.
    nConditions     = 15;

    for counter = 1:nSites
        
        % Baseline computation.
        currSite = siteIdentifiers(counter);
        indices  = statistics(:, 1) == currSite;
        if sum(indices) ~= nConditions
            error('Incorrect number of stimulus conditions per recordings session!');
        end        
        baseline = mean(statistics(indices, 5));  % [-95; 5) ms
        
        % Actual baseline correction.
        indices  = responses(:, 1) == currSite;
        netResponses(indices, :) = netResponses(indices, :) - baseline;
        
    end
    
    updatedResponses = [responses netResponses];
    
end

function updatedResponses = responseNormalization(statistics, responses)

    % Copy responses for normalization.
    normalized      = responses(:, 11:16);
    
    % Site identifiers and their number.
    siteIdentifiers = unique(responses(:, 1));
    nSites          = length(siteIdentifiers);
    
    % Number of different stimulus conditions.
    nConditions     = 15;

    for counter = 1:nSites
        
        % Deriving normalization factor.
        currSite   = siteIdentifiers(counter);
        indices    = statistics(:, 1) == currSite;
        if sum(indices) ~= nConditions
            error('Incorrect number of stimulus conditions per recordings session!');
        end        
        normFactor = max(statistics(indices, 16));  % net response within a window of [25; 325) 
        
        % Actual response normalization.
        indices  = responses(:, 1) == currSite;
        normalized(indices, :) = normalized(indices, :) / normFactor;
        
    end
    
    updatedResponses = [responses normalized];
    
end

function updatedResponses = selectAnalysisWindow(analysisWindow, statistics, responses)

    if ~isequal(statistics(:, 1:4), responses(:, 1:4))
        error('Mismatch between two aggregated statistics variables detected!');
    end
    
    % List of sites with at least one condition showing a significant
    % excitatory response in the full analysis window of 25-325 ms.
    onlyExcitatory   = statistics(:, 15) < 0.05 & statistics(:, 16) > 0;
    siteIds          = unique(statistics(onlyExcitatory, 1));
    
    updatedResponses = statistics(:, [1:4 15 25]);    
    switch analysisWindow
        case 'full'
            updatedResponses = [updatedResponses responses(:, 17:18)];
        case 'early'
            updatedResponses = [updatedResponses responses(:, 19:20)];
        case 'late'
            updatedResponses = [updatedResponses responses(:, 21:22)];
        otherwise
            error('Unknown analysis time window!');            
    end

    % Select only presentations of single stimuli.
    indices = ismember(updatedResponses(:, 4), 1:6);
    updatedResponses = updatedResponses(indices, :);
    
    % Include only site with at least one condition showing a significant
    % excitatory response in the full analysis window of 25-325 ms.
    onlyExcitatory   = ismember(updatedResponses(:, 1), siteIds);
    updatedResponses = updatedResponses(onlyExcitatory, :);
    
end

function positionTolerance(responses, rats, area, selectionRule)

    area_labels = {'V1', 'LI', 'TO', 'UNKNOWN'};
    description = ['Rat(s) = ' mat2str(rats) ', Area(s) = ' area_labels{area}];    
    selection   = ismember(responses(:, 2), rats) & ismember(responses(:, 3), area);
	responses   = responses(selection, :) ; 
    siteIds     = unique(responses(:, 1));
    nSites      = length(siteIds);    
    
    disp(description);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    selectedResponses = [];
    for counter = 1:nSites
        
        indices  = responses(:, 1) == siteIds(counter);
        currSite = responses(indices, :);
        if ~isequal(currSite(:, 4), (1:6)')
            error('Wrong order of stimulus conditions!');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        position1 = [currSite(1, 7) currSite(3, 7) currSite(5, 7) ...
                     currSite(1, 8) currSite(3, 8) currSite(5, 8)];                     
        position2 = [currSite(2, 7) currSite(4, 7) currSite(6, 7) ...
                     currSite(2, 8) currSite(4, 8) currSite(6, 8)];                     
        pvalues1  = [currSite(1, 5) currSite(3, 5) currSite(5, 5)];            
        pvalues2  = [currSite(2, 5) currSite(4, 5) currSite(6, 5)];
              
        [best, worst] = selectionRule(position1, position2, pvalues1, pvalues2);
        if ~isempty(best)
            selectedResponses(end + 1, :) = [best worst];
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    showResults(selectedResponses, description);
    
end

function showResults(selectedResponses, description)

    nDatapoints    = size(selectedResponses, 1);

    if nDatapoints <= 1
        return;
    end
    
    responsesBest  = selectedResponses(:, 1:3);
    responsesWorst = selectedResponses(:, 4:6);
    
    semBest        = std(selectedResponses(:, 1:3)) / sqrt(nDatapoints);
    semWorst       = std(selectedResponses(:, 4:6)) / sqrt(nDatapoints);
    
    figure;
    errorbar(mean(responsesBest), semBest, '-r'), hold on;
    errorbar(mean(responsesWorst), semWorst, '-b');
    set(gca, 'XTick', 1:3), set(gca, 'XTickLabel', {'best', 'intermediate', 'worst'});
    xlabel('stimulus rank'), ylabel('normalized net response');
    legend('Best', 'Worst', 'Location', 'NorthEast');
    title([description ', N = ' num2str(nDatapoints) ' sites']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pBest  = kruskalwallis(responsesBest, [], 'off');
    pWorst = kruskalwallis(responsesWorst, [], 'off');
    
    fprintf('Kruskal-Wallis test: p-values(Best vs. Worst) = %.6f vs. %.6f\n', pBest, pWorst);
    fprintf('Two-sided Wilcoxon matched pairs tests:\n');
    fprintf('Best position:\n');
    fprintf('p-values(Best vs. Worst | Best vs. Intermediate | Intermediate vs. Worst) = %.6f vs. %.6f vs. %.6f\n', ...
            signrank(responsesBest(:, 1), responsesBest(:, 3)), ...
            signrank(responsesBest(:, 1), responsesBest(:, 2)), ...
            signrank(responsesBest(:, 2), responsesBest(:, 3)));
    fprintf('Worst position:\n');
    fprintf('p-values(Best vs. Worst | Best vs. Intermediate | Intermediate vs. Worst) = %.6f vs. %.6f vs. %.6f\n', ...
            signrank(responsesWorst(:, 1), responsesWorst(:, 3)), ...
            signrank(responsesWorst(:, 1), responsesWorst(:, 2)), ...
            signrank(responsesWorst(:, 2), responsesWorst(:, 3)));
    
end

function [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, presentationOrder)

    switch presentationOrder
        case 'oddeven'
            ranking   = 1:3;  % Odd stimulus presentations.
            responses = 4:6;  % Even stimulus presentations.
        case 'evenodd'
            ranking   = 4:6;  % Even stimulus presentations.
            responses = 1:3;  % Odd stimulus presentations.
        otherwise
            error('Unknown choice of stimulus presentation order for ranking!');
    end
    
    if mean(position1(ranking)) > mean(position2(ranking))
        [values, ranks] = sort(position1(ranking), 'descend');
        best            = position1(responses);
        worst           = position2(responses);
        pbest           = pvalues1;
        pworst          = pvalues2;
    else
        [values, ranks] = sort(position2(ranking), 'descend');
        best            = position2(responses);
        worst           = position1(responses);
        pbest           = pvalues2;
        pworst          = pvalues1;
    end
    
    % Rank responses and the corresponding pvalues.
    best   = best(ranks);
    worst  = worst(ranks);
    pbest  = pbest(ranks);
    pworst = pworst(ranks);

end

% No selection at all.
function [best, worst] = selectionRule1(position1, position2, pvalues1, pvalues2)

    [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, 'oddeven');
    
end

% Only significant excitatroy response to the most optimal stimulus
% presented at the best position. In this way we make sure that the best
% position is within a receptive field of an analyzed multi-unit site.
function [best, worst] = selectionRule2(position1, position2, pvalues1, pvalues2)

    [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, 'oddeven');
    
    if pbest(1) >= 0.05
        best  = [];
        worst = [];
    end
    
end

% Significant excitatory response to the most optimal stimulus presented at
% the best position and at least one significant excitatory response to any
% stimulus presented at the worst position. In this way we make sure that
% both position fall within a receptive field of an analyzed multi-unit site.
function [best, worst] = selectionRule3(position1, position2, pvalues1, pvalues2)

    [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, 'oddeven');
    
    if pbest(1) >= 0.05 || (pworst(1) >= 0.05 && pworst(2) >= 0.05 && pworst(3) >= 0.05)
        best  = [];
        worst = [];
    end
    
end

% The same as selection #3 but also requiring stimulus selectivity at the
% best position.
function [best, worst] = selectionRule4(position1, position2, pvalues1, pvalues2)

    [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, 'oddeven');
    
    if pbest(1) >= 0.05 || (pworst(1) >= 0.05 && pworst(2) >= 0.05 && pworst(3) >= 0.05) || (max(best) - min(best)) < 0.1
        best  = [];
        worst = [];
    end
    
end

% The same as selection #3 but also requiring stimulus selectivity at both positions.
function [best, worst] = selectionRule5(position1, position2, pvalues1, pvalues2)

    [best, worst, pbest, pworst] = rankStimuli(position1, position2, pvalues1, pvalues2, 'oddeven');
    
    if pbest(1) >= 0.05 || (pworst(1) >= 0.05 && pworst(2) >= 0.05 && pworst(3) >= 0.05) || max(best) - min(best) < 0.1 || max(worst) - min(worst) < 0.1
        best  = [];
        worst = [];
    end
    
end
