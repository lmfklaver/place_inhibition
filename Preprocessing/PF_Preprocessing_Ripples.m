%PF_Preprocessing_Ripples
%
% PURPOSE
%          Find the max ripple channel found by eye from the text document,
%          find the lfp for this channel, run bz_findRipples over the lfp,
%          and then find the peak ripple channel. If the peak ripple
%          channel is not the same channel found by eye, run over
%          bz_findRipples again with the new channel. 
%
%          After an event rip mat file is created, make a rip file. 
%          
%          Open dat file in neuroscope and load ripple file. See how well,
%          the function did at finding ripples. If it did poorly, change
%          the thresholds given to bz_FindRipples, and try again.
% OUTPUT
%          .ripples.events.mat
%                    ripples             Struct
%                           .timestamps
%                           .peaks
%                           .peakNormedPower
%                           .stdev
%                           .noise
%                           .detectorinfo
%                    ripChan             Numeric
%                    lfp_rip             Struct
%                           .Filename
%                           .duration
%                           .interval
%                           .data
%                           .timestamps
%                           .channels
%                           .samplingRate
%          .rip file (visual aid in neuroscope)
% DEPENDENCIES 
%          Buzcode              https://github.com/buzsakilab/buzcode
%          findRippleLayerChan  from Lianne Klaver
% HISTORY
%          Reagan Bullins 06.09.2021
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
%% Find max ripple channel (chosen by function)
% Find ripples using the channel you chose by eye
    lfp_rip = bz_GetLFP(ripChan);
    ripples = bz_FindRipples(lfp_rip.data, lfp_rip.timestamps,'saveMat',true,'thresholds',[1.5 5.5], 'durations', [15 300]);
    ripples.detectorinfo.detectionchannel = ripChan;
    selRipples = [1:200, length(ripples.timestamps)-200:length(ripples.timestamps)];
% Find the channel the function says is the max ripple
    [peakRipChan] = findRippleLayerChan(basePath, 'selRipples',selRipples);
% If the channel you chose by eye does not match the channel chosen by the
% function, use the function channel
   if ripChan ~= peakRipChan.channel
    ripChan = peakRipChan.channel; % OR by eye pick channel
    lfp_rip = bz_GetLFP(ripChan);
    ripples = bz_FindRipples(lfp_rip.data, lfp_rip.timestamps, 'saveMat',true,'thresholds',[1.5 3], 'durations', [10 300]);
    ripples.detectorinfo.detectionchannel = ripChan;
    save([basename '.ripples.events.mat'], 'ripples','ripChan','lfp_rip');
   else
     save([basename '.ripples.events.mat'], 'ripples','ripChan','lfp_rip');
   end
%% Use to visualize in neuroscope
% make rip file
    makeRipFile