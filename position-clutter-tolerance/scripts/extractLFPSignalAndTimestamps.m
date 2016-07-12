clc;

% Select Events file.
[fileName, dirName] = uigetfile('*.nev', 'Select Events file (*.nev)');
if ~fileName
    error('No file with events selected!');
end

% Extract raw data from the Events file.
[eventTimestamps, ttls] = Nlx2MatEV([dirName fileName], [1 0 1 0 0], 0, 1, 1);
eventDescriptors        = bitshift(ttls, -2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select file with the LFP signal.
[fileName, dirName] = uigetfile('*.ncs', 'Select file with LFPs (*.ncs)');
if ~fileName
    error('No file with LFPs selected!');
end

% Extract raw LFP data.
[lfpTimestamps, channel, frequency, validSamples, rawSignal, header] = Nlx2MatCSC([dirName fileName], [1 1 1 1 1], 1, 1, 1);

% Channel identifier.
if length(unique(channel)) ~= 1
    error('More than one unique channel identifier detected!');
else
    fprintf('Channel/File identifier.....CSC%d.ncs\n', unique(channel) + 1);
end

% Sampling frequency.
if length(unique(frequency)) ~= 1
    error('More than one unique sampling frequency detected!');
else
    samplingFreq = unique(frequency);
    fprintf('Sampling frequency..........%d Hz\n', samplingFreq);
end

% All records must contain 512 valid data points.
numRecord = 512;
if length(unique(validSamples)) ~= 1 || unique(validSamples) ~= numRecord || numRecord ~= size(rawSignal, 1)
    error('Corrupted number of data points per record detected!');
else
    fprintf('Points per record...........%d\n', unique(validSamples));
end

% Continuous LFP signal.
rawSignal  = rawSignal(:)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Align all timestamps with respect to the first recorded event. Then
% convert all thus aligned timestamps to sec. 
timeOrigin      = eventTimestamps(1);
eventTimestamps = (eventTimestamps - timeOrigin) / 10.0 ^ 6; % sec
lfpTimestamps   = (lfpTimestamps - timeOrigin) / 10.0 ^ 6;   % sec

% Derive a timestamp for each sampled LFP signal data point.
dt            = (1.0 / samplingFreq) * (0:(numRecord - 1))';
lfpTimestamps = repmat(lfpTimestamps, numRecord, 1) + repmat(dt, 1, size(lfpTimestamps, 2));
lfpTimestamps = lfpTimestamps(:)';

% Display statistics on the derived timestamps for the LFP signal.
dtStatistics  = 10 ^ 6 * (lfpTimestamps(2:end) - lfpTimestamps(1:end - 1)); % usec
fprintf('Min/Mean/Median/Max.........%.3f/%.3f/%.3f/%.3f usec\n', ...
        min(dtStatistics), mean(dtStatistics), median(dtStatistics), max(dtStatistics));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert the LFP signal from digital units to uV.
adMaxValue = 32767;
inputRange = 200.0;
rawSignal  = inputRange * rawSignal / adMaxValue;

fprintf('ALWAYS CONFIRM THE FOLLOWING VALUES AND, WHEN NEEDED, CORRECT!\n');
fprintf('ADMaxValue/InputRange.......%d/%d\n', adMaxValue, inputRange);
disp(header);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear fileName dirName channel frequency validSamples samplingFreq numRecord;
clear timeOrigin dt dtStatistics adMaxValue inputRange;
