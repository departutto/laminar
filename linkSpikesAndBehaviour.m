%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Last modified on March 31, 2016.
% Copyright by Dzmitry Kaliukhovich.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [trial, before, after] = linkSpikesAndBehaviour(trial, timestamps)

    answers = inputdlg({'Time before stimulus onset, ms', 'Time after stimulus onset, ms'}, '', 1, {'300', '600'});

    if isempty(answers) 
        disp('Analysis time window has not been specified at all!');
        return;
    else
        before = str2num(answers{1});
        after  = str2num(answers{2});
    end
    
    if isempty(before) || isempty(after) || before < 0 || after < 0 
        disp('One of the parameters of the analysis time window has been specified improperly!');
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if isempty(trial)                            || ...
       isempty(timestamps)                       || ...
       any(~isfield(trial, {'onset', 'offset'})) || ...
       trial(1).onset > max(timestamps)          || ...
       trial(end).offset < min(timestamps)
        disp('Behavioural data do not match spike timestamps!');
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i = 1:length(trial)
        lowerBoundary   = trial(i).onset - before * 10.0 ^ 3; % usec.
        upperBoundary   = trial(i).onset + after * 10.0 ^ 3;  % usec.
        spikeIndices    = timestamps >= lowerBoundary & timestamps <= upperBoundary;
        trial(i).spikes = timestamps(spikeIndices);
    end
    
end