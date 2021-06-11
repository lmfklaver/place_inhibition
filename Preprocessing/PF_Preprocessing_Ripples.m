%PF_Preprocessing_Ripples

% Ripple script, meant to run in segments and check in neuroscope
%   Change thresholds in bz_FindRipples, then make a rip file, then check
%   in neuroscope and reacess what thresholds could be changed (do again
%   and compare)
%% Read from text document the max ripple channel (chosen by eye)
% load in the text document
    textContents = strjoin(textread([basename '_RecordingInfo.txt'], '%s'));
    textContents = textContents(find(~isspace(textContents)));
% Find the semgent with the max ripple channel
    segment_idx = strfind(textContents, 'MaxRippleChannel');
    rip_chan_number = textContents(1, segment_idx+17: segment_idx+19); 
% Detect which part of the string is letters and delete
    deleteLetterIdx = isletter(rip_chan_number);
    rip_chan_number(deleteLetterIdx) = [];
    ripChan = str2double(rip_chan_number);
%% 
% Find ripples using the channel you chose by eye
    lfp_rip = bz_GetLFP(ripChan);
    ripples = bz_FindRipples(lfp_rip.data, lfp_rip.timestamps,'saveMat',true,'thresholds',[1.5 5.5], 'durations', [15 300]);
    ripples.detectorinfo.detectionchannel = ripChan;
    selRipples = [1:200, length(ripples.timestamps)-200:length(ripples.timestamps)];
% Find the channel the function says is the max ripple
    [peakRipChan] = findRippleLayerChan(basePath, 'selRipples',selRipples);
% If the channe you chose by eye does not match the channel chosen by the
% function, use the function channel
   if ripChan ~= peakRipChan.channel
    ripChan = peakRipChan.channel; % OR by eye pick channel
    lfp_rip = bz_GetLFP(ripChan);
    ripples = bz_FindRipples(lfp_rip.data, lfp_rip.timestamps, 'saveMat',true,'thresholds',[1.5 5.5], 'durations', [15 300]);
    ripples.detectorinfo.detectionchannel = ripChan;
    save([basename '.ripples.events.mat'], 'ripples','ripChan','lfp_rip');
   else
     save([basename '.ripples.events.mat'], 'ripples','ripChan','lfp_rip');
   end
%% Use to visualize in neuroscope
% make rip file
    makeRipFile