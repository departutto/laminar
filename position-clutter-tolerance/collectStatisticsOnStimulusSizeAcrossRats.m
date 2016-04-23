function collectStatisticsOnStimulusSizeAcrossRats(statistics, stimulus_size, area_labels)
    
    % Only significant excitatory response in the full analysis window.
    selection  = statistics(:, 15) < 0.05 & statistics(:, 16) > 0;    
    statistics = statistics(selection, :); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Separately per rat and brain area. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    rats  = unique(statistics(:, 2));
    nRats = length(rats);
    
    for counterRat = 1:nRats
        
        currRat = rats(counterRat);
        areas   = unique(statistics(:, 3));
        nAreas  = length(areas);
        
        for counterArea = 1:nAreas
           
            currArea          = areas(counterArea);
            [siteIds, nSites] = selectSiteIdentifiers(statistics, currRat, currArea);
            
            if nSites <= 1
                continue;
            end

            position1 = stimulus_size(siteIds, 2:3);
            position2 = stimulus_size(siteIds, 4:5);
            
            fprintf('\n\nRat = %5d, Brain area = %s, N(sites) = %02d\n', currRat, area_labels{counterArea}, nSites);
            
            showDescriptiveStatistics('Position #1', position1);
            showDescriptiveStatistics('Position #2:', position2);
            showDescriptiveStatistics('Both position combined:', [position1; position2]);
            showDescriptiveStatistics('abs(Position #1 - Position #2):', position1 - position2);
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Separately per brain area across rats.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sitesV1 = selectSiteIdentifiers(statistics, [68430 68474 68481 68547], 1);
    sitesLI = selectSiteIdentifiers(statistics, [68520 68481 68547], 2);
   
    position1V1 = stimulus_size(sitesV1, 2:3);
    position2V1 = stimulus_size(sitesV1, 4:5);
    
    position1LI = stimulus_size(sitesLI, 2:3);
    position2LI = stimulus_size(sitesLI, 4:5);
    
    fprintf('\n\nAcross all rats in V1:\n');
    showDescriptiveStatistics('Position #1:', position1V1);
	showDescriptiveStatistics('Position #2:', position2V1);
    showDescriptiveStatistics('Both position combined:',        [position1V1;  position2V1]);
    showDescriptiveStatistics('abs(Position #1 - Position #2):', position1V1 - position2V1);
    
    fprintf('\n\nAcross all rats in LI:\n');
    showDescriptiveStatistics('Position #1:', position1LI);
	showDescriptiveStatistics('Position #2:', position2LI);
    showDescriptiveStatistics('Both position combined:',        [position1LI;  position2LI]);
    showDescriptiveStatistics('abs(Position #1 - Position #2):', position1LI - position2LI);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compare stimulus size between two different selections.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    compareTwoSelections('V1 versus LI across rats:', [position1V1 position2V1], [position1LI position2LI]);
    
end

function [siteIds, nSites] = selectSiteIdentifiers(statistics, rats, areas)

    selection = ismember(statistics(:, 2), rats) & ismember(statistics(:, 3), areas);
    siteIds   = unique(statistics(selection, 1));
    nSites    = length(siteIds);

end

function showDescriptiveStatistics(description, data)

    data = abs(data);
    
    fprintf('%s\n', description);
    fprintf('Horizontal axis versus Vertical axis:\n');
    fprintf('N(data points) ........ %d\n', size(data, 1));
    fprintf('Minimum values ........ %6.3f vs. %6.3f visual degrees\n', min(data));
    fprintf('Mean values ........... %6.3f vs. %6.3f visual degrees\n', mean(data));
    fprintf('Median values ......... %6.3f vs. %6.3f visual degrees\n', median(data));
    fprintf('Std values ............ %6.3f vs. %6.3f visual degrees\n', std(data));
    fprintf('Maximum values ........ %6.3f vs. %6.3f visual degrees\n', max(data));
    
    fprintf('25-75%% Percentiles:\n');
    fprintf('Horizontal axis ....... %6.3f vs. %6.3f visual degrees\n', prctile(data(:, 1), [25.0 75.0]));
    fprintf('Vertical axis ......... %6.3f vs. %6.3f visual degrees\n', prctile(data(:, 2), [25.0 75.0]));

end

function compareTwoSelections(description, data1, data2)

    fprintf('\n\n%s\n', description);
    fprintf('N(data points) #1 ..... %d\n', size(data1, 1));
    fprintf('N(data points) #2 ..... %d\n', size(data2, 1));
    
    horizontalAvg1 = (data1(:, 1) + data1(:, 3)) / 2.0;
    verticalAvg1   = (data1(:, 2) + data1(:, 4)) / 2.0;
    
    horizontalAvg2 = (data2(:, 1) + data2(:, 3)) / 2.0;
    verticalAvg2   = (data2(:, 2) + data2(:, 4)) / 2.0;
    
    fprintf('Testing averages across the two positions:\n');
    fprintf('Two-sided Mann-Whitney U test
end