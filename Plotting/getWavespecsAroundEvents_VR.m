% PURPOSE
%          Find wavespecs around Virtual Reality Maze events including
%          grating switch (green to blue), water reward, and stim location.
%          Wavespecs are further split between pre baseline, stim, and post
%          baseline trials. Each figure is saved in the Figures folder in
%          the recording folder under wavespec.
% INPUTS
%          basePath                String : path with data
%          analogin_VR             Struct : position and timestamps of wheel
%          lfp_channel             Numeric: lfp channel to calculate over
%          Time                    Struct : .start and .stop times of all trials
%          VR_BL1_Time             Struct : .start and .stop times of pre baseline trials
%          VR_Stim_Time            Struct : .start and .stop times of stim trials
%          VR_BL2_Time             Struct : .start and .stop times of post baseline trials
%          tr_ep                   Matrix : (n trials x 2) start and stop times of each wheel trial
%          gratingSwitch_pos       Numeric: Analogin value where grating switch occurs
%          reward_pos              Numeric: Analogin value where reward occurs
%          stim_pos                Numeric: Analogin value where opto stim occurs
% OUTPUTS
%          Graphs of the following, plus the matrix to make each graph:
%          wavespec_gratings_all   
%          wavespec_gratings_preBL
%          wavespec_gratings_stim
%          wavespec_gratings_postBL
%          wavespec_reward_all
%          wavespec_reward_preBL
%          wavespec_reward_stim
%          wavespec_reward_postBL
%          wavespec_stim_all
%          wavespec_stim_preBL
%          wavespec_stim_stim
%          wavespec_stim_postBL
% DEPENDENCIES
%          Buzcode                 https://github.com/buzsakilab/buzcode
%          Place Inhibition        https://github.com/rcbullins/place_inhibition
% HISTORY
%          Reagan Bullins 05.11.2021
%% Run wavespecs around specified events - grating change, reward location,
% and stim location

% Stim Location Power Spectra:
    % All Trials
         subplot(3,4,1);     
         [wavespec_stim_all] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, Time.VR, tr_ep, stim_pos);
         title('Stim Location: All trials');
         xlabel('Time to stim (ms)');
    % Pre baseline
          subplot(3,4,2);
          [wavespec_stim_preBL] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, stim_pos);       
          title('Stim Location: Pre baseline trials');
          xlabel('Time to stim (ms)');
    % Stim
          subplot(3,4,3);
          [wavespec_stim_stim] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, stim_pos);       
          title('Stim Location: Stim trials');
          xlabel('Time to stim (ms)');
    % Post baseline
          subplot(3,4,4);
          [wavespec_stim_postBL] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, stim_pos);       
          title('Stim Location: Post baseline trials');
          xlabel('Time to stim (ms)');
% Grating Power Spectra:
    % Averaged over all VR trials
         subplot(3,4,5);
         [wavespec_gratings_all] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, Time.VR, tr_ep, gratingSwitch_pos);
         title('Grating Switch: All trials');
         xlabel('Time to grating switch (ms)');
    % Average over all pre baseline trials
         subplot(3,4,6);
         [wavespec_gratings_preBL] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, gratingSwitch_pos);
         title('Grating Swith: Pre baseline trials');
         xlabel('Time to grating switch (ms)');
    % Averaged over all stim trials
         subplot(3,4,7);
         [wavespec_gratings_stim] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, gratingSwitch_pos);
         title('Grating Switch: Stim trials');
         xlabel('Time to grating switch (ms)');
    % Average over all post baseline trials
         subplot(3,4,8); 
         [wavespec_gratings_postBL] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, gratingSwitch_pos);       
         title('Grating Switch: Post baseline trials');
         xlabel('Time to grating switch (ms)');
% Reward Power Spectra:
    % All Trials
         subplot(3,4,9);
         [wavespec_reward_all] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, Time.VR, tr_ep, reward_pos);
         title('Reward Location: All trials');
         xlabel('Time to reward (ms)');
    % Pre baseline
         subplot(3,4,10);
         [wavespec_reward_preBL] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, reward_pos);       
         title('Reward Location: Pre baseline trials');
         xlabel('Time to reward (ms)');
    % Stim
         subplot(3,4,11);
         [wavespec_reward_stim] = getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, reward_pos);       
         title('Reward Location: Stim trials');
         xlabel('Time to reward (ms)');
    % Post baseline
         subplot(3,4,12);
         [wavespec_reward_postBL] =getWavespec_AroundEvent(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, reward_pos);       
         title('Reward Location: Post baseline trials');
         xlabel('Time to reward (ms)');

%% Save fig
          savefig('WavespecsAroundVREvents.fig');