%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Last modified on March 31, 2016.
% Copyright by Dzmitry Kaliukhovich.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[filenameKWIK, directoryKWIK] = uigetfile('*.kwik', 'Select file with sorted spike waveforms (*.kwik)', cd, 'MultiSelect', 'off');

% No file has been selected.
if isnumeric(filenameKWIK)
    clear *KWIK;
    return;
end

% Full path to the file with spike timestamps and clusters information.
fullpathKWIK = [directoryKWIK filenameKWIK];

% Find the starting index of the .KWIK file extension.
extensionIndex = strfind(fullpathKWIK, '.kwik');
if isempty(extensionIndex)
    clear extensionIndex;
    return;
end

% Full path to the file with raw and filtered spike waveforms.
fullpathKWX = [fullpathKWIK(1:extensionIndex) 'kwx'];

clear filenameKWIK directoryKWIK extensionIndex;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    % Note that the channel group number refers to the shank number which
    % starts from 0. Change if needed.
    timings           = hdf5read(fullpathKWIK, '/channel_groups/0/spikes/time_samples');
    clusters          = hdf5read(fullpathKWIK, '/channel_groups/0/spikes/clusters/main');
    waveformsRaw      = hdf5read(fullpathKWX,  '/channel_groups/0/waveforms_raw');
    waveformsFiltered = hdf5read(fullpathKWX,  '/channel_groups/0/waveforms_filtered'); 
catch err
    error('Something went wrong when uploading data into the Matlab workspace!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Unique cluster identifiers.
clusterIdentifiers = unique(clusters);

% Number of different clusters. 
nClusters = length(clusterIdentifiers);

% Number of detected spikes in each cluster.
nSpikes = [];

% String description of all retrieved clusters in a form "Cluster # (Number of detected spikes)".
clusterDescriptors = {};

for counter = 1:nClusters
    currentCluster              = clusterIdentifiers(counter);
    nSpikes(end + 1)            = sum(clusters == currentCluster);
    clusterDescriptors{end + 1} = [num2str(currentCluster) ' (' num2str(nSpikes(counter)) ')'];
end

% Display a list selection dialog box with all the retrieved clusters.
[selection, ok]  = listdlg('PromptString', 'Select a cluster (or clusters)', ...
                           'SelectionMode', 'multiple', ...
                           'ListString', clusterDescriptors); 
                       
% List of cluster identifiers selected by user.
selectedClusters = clusterIdentifiers(selection);
                       
clear counter currentCluster clusterDescriptors selection ok;

% No cluster has been selected.
if isempty(selectedClusters)
    clear selectedClusters;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% True, if a spike belongs to one of the selected clusters, and false otherwise.
selectedSpikeIndices = false(sum(nSpikes), 1);

% Gather all spikes of the selected clusters.
for counter = 1:length(selectedClusters)
    currentCluster       = selectedClusters(counter);
    selectedSpikeIndices = selectedSpikeIndices | clusters == currentCluster;
end
clear counter currentCluster;

msgbox({['Selected clusters = ' mat2str(selectedClusters)], ['Total number of spikes = ' num2str(sum(selectedSpikeIndices))]});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

button = questdlg('Would you like to extract timestamps of the selected spikes in usec?', 'Additional option');

% Other than the "Yes" button has been pushed.
if ~strcmp(button, 'Yes')
    clear button;
    return;
end

[filenameMAT, directoryMAT] = uigetfile('*.mat', 'Select file with timestamps (*.mat)', fileparts(fullpathKWIK), 'MultiSelect', 'off');
fullpathMAT                 = [directoryMAT filenameMAT];
clear button filenameMAT directoryMAT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Retrieve a list of variable names stored in the specified .mat file.
info = whos('-file', fullpathMAT);
vars = {info(1:end).name};

% Terminate if the specified .mat file does not contain variable
% 'timeStamps' (spike timestamps in usec).
if any(cellfun(@(x) isequal(x, 'timeStamps'), vars))
    load(fullpathMAT, 'timeStamps');
    clear info vars;
else
    disp('Specified .mat file does not contain spike timestamps in usec!');
    clear info vars;
    return;
end

if max(timings) > length(timeStamps)
    disp('Max timestamp index exceeds the range of available spike timestamps stored in the specified .mat file!');
else
    selectedSpikeTimestampIndices = timings(selectedSpikeIndices);
    selectedSpikeTimestampsInUsec = timeStamps(selectedSpikeTimestampIndices);
end

selectedSpikeTimestampsInSec = (selectedSpikeTimestampsInUsec - timeStamps(1)) / 10 ^ 6;
