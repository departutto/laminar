function psths = plotAveragePSTH4RunningBallSetup

    % Select Events file.
    [fileName, dirName] = uigetfile('*.nev', 'Select Events file (*.nev)');
    if ~fileName
        error('No file with events selected!');
    end

    % Extract raw data from the Events file.
    [eventTimestamps, ttls] = Nlx2MatEV([dirName fileName], [1 0 1 0 0], 0, 1, 1);
    eventDescriptors        = [bitand(ttls', 65280) bitand(ttls', 255)];

    extractSpikeWaveformsAndTimestamps;

    % Align all timestamps with respect to the first recorded event. Then
    % convert all thus aligned timestamps to sec. 
    timeOrigin      = eventTimestamps(1);
    eventTimestamps = (eventTimestamps - timeOrigin) / 10.0 ^ 6;               % sec
    spikeTimestamps = (selectedSpikeTimestampsInUsec - timeOrigin) / 10.0 ^ 6; % sec

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Photocell events.
    indices = find(eventDescriptors(:, 2) == 128)';

    % Time interval between two consecutive photocell events (presumably in sec).
    durations = eventTimestamps(indices(2:end)) - eventTimestamps(indices(1:end - 1));
    
    % Detect stimulus onset and offset (the cut-off values are in sec). The
    % first and second rows correspond to stimulus onset and offset.
    stimIndices = [indices(1:end - 1); indices(2:end)];
    stimIndices = stimIndices(:, durations >= 0.46 & durations <= 0.49);
    stimTimings = [eventTimestamps(stimIndices(1, :)); eventTimestamps(stimIndices(2, :))];
    
    % Number of stimulus presentations.
    nStimulus = size(stimTimings, 2); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    psths    = [];
    preStim  = -0.305;
    stimDur  = 0.500;
    postStim = stimDur + 0.305;
    step     = 0.010;
    bins     = preStim:step:postStim;

    for i = 1:nStimulus
        tmpBins = bins + stimTimings(1, i);
        tmpArr  = [];
        for j = 2:length(tmpBins)
            tmpArr(end + 1) = sum(spikeTimestamps >= tmpBins(j - 1) & spikeTimestamps < tmpBins(j)) / step;
        end
        psths(end + 1, :) = tmpArr;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure;
    plot(mean(psths), 'LineWidth', 2), hold on;
    xlim([1 size(psths, 2)]);
    plot([31 31], get(gca, 'YLim'), '--k');
    plot([81 81], get(gca, 'YLim'), '--k');
    set(gca, 'XTick', [1 31 81 111]), set(gca, 'XTickLabel', [-300 0 500 800]);
    xlabel('time, ms'), ylabel('firing rate, spikes/sec');
    title(['N(stimulus presentations) = ' num2str(nStimulus)]);
    
end