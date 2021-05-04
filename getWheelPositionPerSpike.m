function [spkEpVoltIdx] = getWheelPositionPerSpike(basePath, tr_ep)

% Purpose: Gets wheel voltage at every spike time

% Input:  basePath: path with data
%         tr_ep: start and stop of each trial
%         length_cm_track: how long the running wheel track is in cm
%         
% Output: spkEpVoltIdx (an array of voltages correpsonding to each spike
% split into wheel trials)

% Reagan 2021.05.04

%%
        basename = bz_BasenameFromBasepath(basePath);
        load([basename '_analogin.mat']);
        load([basename '.spikes.cellinfo.mat']);
        ts  = analogin.ts;
        pos = analogin.pos;
    %Generate spk_ep (find the position of each spike in each trial lap)
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