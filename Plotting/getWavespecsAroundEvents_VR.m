% Run wavespecs around specified events - grating change, reward location,
% and stim location
% Grating Power Spectra:
    % Averaged over all VR trials
         [wavespec_gratings_all] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR, tr_ep, gratingSwitch_pos);
         title('Grating Switch: All trials');
         xlabel('Time to grating switch (ms)');
         savefig('Gratings_AllTrials.fig');
    % Average over all pre baseline trials
         [wavespec_gratings_preBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, gratingSwitch_pos);
         title('Grating Swith: Pre baseline trials');
         xlabel('Time to grating switch (ms)');
         savefig('Gratings_PreBaselineTrials.fig');
    % Averaged over all stim trials
         [wavespec_gratings_stim] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, gratingSwitch_pos);
         title('Grating Switch: Stim trials');
         xlabel('Time to grating switch (ms)');
         savefig('Gratings_StimTrials.fig');
    % Average over all post baseline trials
         [wavespec_gratings_postBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, gratingSwitch_pos);       
         title('Grating Switch: Post baseline trials');
         xlabel('Time to grating switch (ms)');
         savefig('Gratings_PostBaselineTrials.fig');
% Reward Power Spectra:
    % All Trials
        [wavespec_reward_all] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR, tr_ep, reward_pos);
         title('Reward Location: All trials');
         xlabel('Time to reward (ms)');
         savefig('Reward_AllTrials.fig');
    % Pre baseline
         [wavespec_reward_preBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, reward_pos);       
         title('Reward Location: Pre baseline trials');
         xlabel('Time to reward (ms)');
         savefig('Reward_PreBaselineTrials.fig');
    % Stim
         [wavespec_reward_stim] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, reward_pos);       
         title('Reward Location: Stim trials');
         xlabel('Time to reward (ms)');
         savefig('Reward_StimTrials.fig');
    % Post baseline
         [wavespec_reward_postBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, reward_pos);       
         title('Reward Location: Post baseline trials');
         xlabel('Time to reward (ms)');
         savefig('Reward_PostBaselineTrials.fig');
% Stim Location Power Spectra:
    % All Trials
        [wavespec_stim_all] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR, tr_ep, stim_pos);
         title('Stim Location: All trials');
         xlabel('Time to stim (ms)');
         savefig('Stim_AllTrials.fig');
    % Pre baseline
          [wavespec_stim_preBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL1_Time, tr_ep, stim_pos);       
          title('Stim Location: Pre baseline trials');
          xlabel('Time to stim (ms)');
          savefig('Stim_PreBaselineTrials.fig');
    % Stim
          [wavespec_stim_stim] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_Stim_Time, tr_ep, stim_pos);       
          title('Stim Location: Stim trials');
          xlabel('Time to stim (ms)');
          savefig('Stim_StimTrials.fig');
    % Post baseline
          [wavespec_stim_postBL] = getPowerSpectrum_Gratings(basePath, analogin_VR, lfp_channel, VR_BL2_Time, tr_ep, stim_pos);       
          title('Stim Location: Post baseline trials');
          xlabel('Time to stim (ms)');
          savefig('Stim_PostBaselineTrials.fig');