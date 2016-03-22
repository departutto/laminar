function [signal, timeStamps, samplingFreq, headers, srcFileNames, srcDirectory] = convertNCS2Dat
    
    signal       = [];              % AD units.
    timeStamps   = [];              % usec.
    samplingFreq = [];              % Hz.
    headers      = {};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [srcFileNames, srcDirectory] = uigetfile('*.ncs', 'Select file(s) with continuously sampled signal (*.ncs)', cd, 'MultiSelect', 'on');
    if isnumeric(srcFileNames)
        disp('No file with continuously sampled signal has been selected!');
        return;     
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ischar(srcFileNames)         % Single file selected.
        srcFileNames = {srcFileNames};
    end

    signal = [];
    for counter = 1:length(srcFileNames)
        disp(['.ncs File: ' srcDirectory srcFileNames{counter}]);
        [signal(end + 1, :), timeStamps(end + 1, :), samplingFreq(end + 1), headers{end + 1}] = processEachChannel([srcDirectory srcFileNames{counter}]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if size(timeStamps, 1) > 1 && any(max(timeStamps) - min(timeStamps))
        disp('Time stamps vary across different channels of the same recordings session!');
        return;
    end
    timeStamps = timeStamps(1, :);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    samplingFreq = unique(samplingFreq);
    if length(samplingFreq) ~= 1
        disp('Sampling frequency varies across different channels of the same recordings session!');
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    disp(['Signal duration (given a sampling frequency of 32556 Hz) = ' num2str(size(signal, 2) / 32556) ' sec']);
    
    minSignalValue = min(min(signal));
    maxSignalValue = max(max(signal));
    
    if minSignalValue < -32768 || maxSignalValue > 32767
        disp('The data type int16 cannot properly represent the retrieved signal(s)!');
        return;
    else
        disp(['Min(signal) = ' num2str(minSignalValue) ' AD units (>= -32768)']);
        disp(['Max(signal) = ' num2str(maxSignalValue) ' AD units (<= 32767)']);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dt = timeStamps(2:end) - timeStamps(1:end - 1);    
    disp(['Min(dt)     = ' num2str(min(dt)) ' usec']);
    disp(['Mean(dt)    = ' num2str(mean(dt)) ' usec']);
    disp(['Median(dt)  = ' num2str(median(dt)) ' usec']);
    disp(['Max(dt)     = ' num2str(max(dt)) ' usec']);
    disp(['Desired(dt) = ' num2str(10.0 ^ 6 / samplingFreq) ' usec']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [destFileName, destDirectory] = uiputfile('*.dat', 'Save your data', 'chunk');    
    if ~isnumeric(destFileName)
        fid = fopen([destDirectory destFileName], 'w');
        fwrite(fid, signal, 'int16');
        fclose(fid);
        save([destDirectory destFileName '.mat'], 'timeStamps', 'samplingFreq', 'headers', 'srcFileNames', 'srcDirectory');
    end    
    
end

function [signal, timeStamps, samplingFreq, header] = processEachChannel(fileName)
    
    [timeStamps, channel, samplingFreq, validSamples, signal, header] = Nlx2MatCSC(fileName, [1 1 1 1 1], 1, 1, 1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % Continuously sampled signal in AD units.
    signal = signal(:)';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    channel      = unique(channel);
    samplingFreq = unique(samplingFreq);
    validSamples = unique(validSamples);
    
    if length(channel) ~= 1
        error('More than one channel identifier has been detected!');
    end

    if length(samplingFreq) ~= 1
        error('More than one sampling frequency has been detected!');
    end
    
    if length(validSamples) ~= 1
        error('More than one number of valid samples per record/chunk has been detected!');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % Remove the last record/chunk of data.
    timeStamps = timeStamps(1:end - 1);
    signal     = signal(1:end - validSamples);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dt         = 10.0 ^ 6 / samplingFreq * (0:(validSamples - 1))'; % usec.
    timeStamps = repmat(timeStamps, validSamples, 1);               % usec.
    timeStamps = timeStamps + repmat(dt, 1, size(timeStamps, 2));    
    timeStamps = timeStamps(:)';
    
end
