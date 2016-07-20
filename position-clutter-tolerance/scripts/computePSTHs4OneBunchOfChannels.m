function computePSTHs4OneBunchOfChannels(experimentFile, timestampsFile, nevFile, kwikFile, resultsFile)
    
    try
        load(experimentFile);                                              % sec
        load(timestampsFile);                                              % usec
        timeOrigin            = Nlx2MatEV(nevFile, [1 0 0 0 0], 0, 3, 1);  % usec
        spikeTimestampIndices = hdf5read(kwikFile, '/channel_groups/0/spikes/time_samples');
        spikeAssignedClusters = hdf5read(kwikFile, '/channel_groups/0/spikes/clusters/main');
        spikeTimestamps       = timeStamps(spikeTimestampIndices);         % usec
        spikeTimestamps       = (spikeTimestamps - timeOrigin) / 10 ^ 6;   % sec
    catch err
        error('Something went wrong when uploading data into the Matlab workspace!');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Unique identifiers of clusters of distinct spiking activity.
    clusterIds = unique(spikeAssignedClusters);
    
    % Number of thus identified (see above) clusters of spiking activity.
    nClusters  = length(clusterIds);
    
    % Number of detected spikes in each cluster. 
    nSpikes = [];
    
    % PSTHs per stimulus presentation for each cluster.
    psths = {};
    
    % Derive PSTHs per stimulus presentation for each cluster. 
    for counter = 1:nClusters
        
        currCluster      = clusterIds(counter);
        currSelection    = spikeAssignedClusters == currCluster;
        currTimestamps   = spikeTimestamps(currSelection);
        nSpikes(end + 1) = sum(currSelection);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fprintf('Analyzing cluster #%d (N = %d spikes)\n', currCluster, nSpikes(end));
        psths{end + 1}   = computePSTHsPerStimPresentation(experiment, currTimestamps); 
        
    end
    
    save(resultsFile, 'psths', 'nSpikes', 'clusterIds');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    xticks  = [1 31 61 91];
    xlabels = {'-300', '0', '300', '600'}; 
    [dirName, fileName] = fileparts(resultsFile);

    for counter = 1:nClusters
        currCluster = clusterIds(counter);
        figure;
        plot(mean(psths{counter}(:, 3:end)), '-b', 'LineWidth', 2), hold on;
        xlim([xticks(1) xticks(end)]);
        plot([xticks(2) xticks(2)], get(gca, 'YLim'), '--k');
        plot([xticks(3) xticks(3)], get(gca, 'YLim'), '--k');
        set(gca, 'XTick', xticks), set(gca, 'XTickLabel', xlabels);
        xlabel('time, msec'), ylabel('firing rate, spikes/sec');
        title(['Cluster #' num2str(currCluster) ' (' num2str(nSpikes(counter)) ' spikes)']);     
        saveas(gcf, sprintf('%s\\%s_cluster_%02d', dirName, fileName, currCluster), 'jpg');
        close(gcf);
    end

end

function psths = computePSTHsPerStimPresentation(experiment, spikeTimestamps)

    % PSTHs per stimulus presentation.
    psths    = [];
    
    % Specification of the analysis time window (all in sec).
    preStim  = -0.305;                % before stimulus onset
    stimDur  = 0.300;                 % stimulus duration
    postStim = stimDur + 0.305;       % after stimulus offset
    step     = 0.010;                 % bin width
    bins     = preStim:step:postStim; % time bins
    
    % Number of trials (blocks of stimulus presentations).
    nTrials  = length(experiment.trial);
    
    % Number of stimulus presentations in one trial (block).
    nStim    = 226;

    for trialNo = 1:length(experiment.trial)
        fprintf('Trial #%02d: Stimulus #', trialNo);
        for stimNo = 1:nStim
            fprintf('%03d', stimNo);
            
            % Compute PSTH for the currently analyzed stimulus presentation.
            currBins = bins + experiment.trial(trialNo).photoevents(2 * stimNo - 1);
            currPSTH = [];
            for binNo = 2:length(currBins)
                currPSTH(end + 1) = sum(spikeTimestamps >= currBins(binNo - 1) & spikeTimestamps < currBins(binNo)) / step; % spikes/sec
            end
            psths(end + 1, :) = [trialNo experiment.trial(trialNo).condition(stimNo) currPSTH];
            
            if stimNo ~= nStim
                fprintf('\b\b\b');
            end
        end
        fprintf('\n');
    end

end
