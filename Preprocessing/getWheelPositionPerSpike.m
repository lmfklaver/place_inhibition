function [spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep)
% PURPOSE
%          Gets wheel voltage (analogin value) at every spike time.
% INPUTS
%          basePath       String: path with data
%          tr_ep          Matrix: (n trials x 2) start and stop time of each trial
%         
% OUTPUT 
%          spkEpVoltage   Array: Identical dimensions to spikes.times
%                                array, corresponding position in voltages
% DEPENDENCIES
%          Buzcode        https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 04.05.2021

%%
% Load the name of the recording session
    basename = bz_BasenameFromBasepath(basePath);
    load([basename '_analogin.mat']);
    load([basename '.spikes.cellinfo.mat']);
    ts  = analogin.ts;  
    pos = analogin.pos;
% Generate spk_ep (find the position of each spike in each trial lap)
    % For every cell, for every trial, find the spikes in that trial, and
    % then find the voltage at every spike
        for iUnit = 1:length(spikes.UID)
            for iTr = 1:length(tr_ep)
                [status,interval] = InIntervals(spikes.times{iUnit},tr_ep);
                spk_ep{iUnit}.trial{iTr} = spikes.times{iUnit}(interval==iTr); 
              % find associated voltage to each spike in the trial
                spkEpVoltIdx = find(ismember(ts,spk_ep{iUnit}.trial{iTr}));
                spkEpVoltage{iUnit}.trial{iTr} = pos(spkEpVoltIdx);
            end
        end
        
end