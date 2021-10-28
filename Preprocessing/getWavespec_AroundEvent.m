function [wavespec_segment] = getWavespec_AroundEvent(basePath, analogin_segment, lfp_channel, Segment_Time, trials_time, event_point, varargin)
% PURPOSE 
%          Makes power spectrum comparing different VR gratings 
% INPUTS
%          Segment_Time       Struct : .start and .stop time
%          lfp_channel        Numeric: idx channel you want to use
%          basePath           String : path with data in it
%          analogin_segment   Struct : position and timestamps of analogin
%          trials_time        Matrix : start and stop times of laps in VR
%          doLFPClean         Boolean: default is true, notch filter 60 hz over lfp
%          doSplitLFP         Boolean: default is true, splits lfp and calculates power spectra for each
%                                      segment and then averages
%          movmean_win        Numeric: default is 1000, smoothing window for movmean 
%          event_point        Numeric: analogin value where event occurs
% OUTPUTS
%          wavespec_segment   Struct : IRASA, each power/freq time series for
%                                      each occurance of event
%          wavepsec plot around specific event
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 05.11.2021
%% Inputs
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1000,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win      = p.Results.movmean_win;
%% Load analogin for VR
basename = bz_BasenameFromBasepath(basePath);
cd(basePath);
%% get lfp data around the grating change for all trials
        nfreqs = 100;
        lfp = bz_GetLFP(lfp_channel); %just need this for sampling rate
    %make a lfp matrix (rows = trials, columns = time)
    wavespec_matrix = zeros(nfreqs,lfp.samplingRate+1, length(trials_time)); %lfp sampling rate+1 (1 second of data)
        % only pick trials during the specified VR Time
         tr_ep_specific_idx = find(trials_time(:,1) > Segment_Time.start & trials_time(:,1) < Segment_Time.stop);
         tr_ep_specific = trials_time(tr_ep_specific_idx,:);
    % For each wheel lap in the VR time, find the analogin
    for itrial = 1:length(tr_ep_specific)
         %find the analogin position data for the specific trial
         analogin_trial_data_idx = find(analogin_segment.ts >  tr_ep_specific(itrial,1)& analogin_segment.ts <  tr_ep_specific (itrial,2));
         analogin_trial_data = analogin_segment.pos(analogin_trial_data_idx);
         %find the point in the analogin position data for the specific
         %trial where the wheel voltage is equal to the switch grating
         %value (round the analogin_trial_data to the second decimal)
         analogin_idx_switch = find(round(analogin_trial_data,3) == round(event_point,3));
         %take the first match as the switch grating point (animal may stay
         %still for a while in location)
         if analogin_idx_switch > 0
              analogin_idx_switch = analogin_idx_switch(1); 
         else %temporary fix to bug
             continue;
         end
         %find the index of the analogin switch for this trial, in the
         %complete analogin vector
         analogin_idx_switch = analogin_idx_switch + analogin_trial_data_idx(1);%analogin idx for trial not total analogin
        %find lfp point aligning to analogin_idx_switch (30000 is sampling
        %rate of analogin, 1250 is sampling rate of lfp)
         lfp_center_idx = (analogin_idx_switch/30000)*lfp.samplingRate;
         % round the indexes to full numbers, and find the lfp data around
         % the analogin switch point
         lfp_trial.data = double(lfp.data(round(lfp_center_idx-(lfp.samplingRate/2)):round(lfp_center_idx+(lfp.samplingRate/2))));
         lfp_trial.timestamps = lfp.timestamps(round(lfp_center_idx-(lfp.samplingRate/2)):round(lfp_center_idx+(lfp.samplingRate/2)));
         lfp_trial.samplingRate = lfp.samplingRate;
         %convert to microvolts
         lfp_trial.data = lfp_trial.data * 0.195;
         wavespec = bz_WaveSpec(lfp_trial);
         %take absolute value to find magnitude of the values and get rid
         %of imaginary numbers
         wavespec_matrix(:,:,itrial) = abs(wavespec.data');
    end
% Plot it
wavespec_matrix = mean(wavespec_matrix, 3);
imagesc(wavespec_matrix);
hold on;
xticks([1 round(lfp.samplingRate/2+1) lfp.samplingRate+1]);
xticklabels({'-500','0','500'});
yticks([1 20 40 60 80 100]);
yticklabels({num2str(round(wavespec.freqs(1),1)),num2str(round(wavespec.freqs(20),1)),num2str(round(wavespec.freqs(40),1)),...
           num2str(round(wavespec.freqs(60),1)),num2str(round(wavespec.freqs(80),1)),num2str(round(wavespec.freqs(100),1))});
ylabel('Frequency (Hz)');
set(gca,'Ydir','normal');
cb = colorbar;
ylabel(cb, 'Power (mV)');
%caxis([0 190]);
wavespec_segment = wavespec_matrix;
end