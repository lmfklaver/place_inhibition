% Grating Power Spectra:
    % Averaged over all VR trials
         [wavespec_gratings_all_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Time, tr_ep_no, gratingSwitch_pos);
         title('No VR Grating Switch: All trials');
    % Average over all pre baseline trials
         [wavespec_gratings_preBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL1_Time, tr_ep_no, gratingSwitch_pos);
         title('No VR Grating Swith: Pre baseline trials');
    % Averaged over all stim trials
         [wavespec_gratings_stim_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Stim_Time, tr_ep_no, gratingSwitch_pos);
         title('No VR Grating Switch: Stim trials');
    % Average over all post baseline trials
         [wavespec_gratings_postBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL2_Time, tr_ep_no, gratingSwitch_pos);       
         title('No VR Grating Switch: Post baseline trials');
% Reward Power Spectra:
    % All Trials
        [wavespec_gratings_all_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Time, tr_ep_no, reward_pos);
         title('No VR Reward Location: All trials');
    % Pre baseline
         [wavespec_reward_preBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL1_Time, tr_ep_no, reward_pos);       
         title('No VR Reward Location: Pre baseline trials');
    % Stim
         [wavespec_reward_stim_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Stim_Time, tr_ep_no, reward_pos);       
         title('No VR Reward Location: Stim trials');
    % Post baseline
         [wavespec_reward_postBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL2_Time, tr_ep_no, reward_pos);       
         title('No VR Reward Location: Post baseline trials');
% Stim Location Power Spectra:
    % All Trials
        [wavespec_gratings_all_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Time, tr_ep_no, stim_pos);
         title('No VR Stim Location: All trials');
    % Pre baseline
          [wavespec_stim_preBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL1_Time, tr_ep_no, stim_pos);       
          title('No VR Stim Location: Pre baseline trials');
    % Stim
          [wavespec_stim_stim_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_Stim_Time, tr_ep_no, stim_pos);       
          title('No VR Stim Location: Stim trials');
    % Post baseline
          [wavespec_stim_postBL_noVR] = getPowerSpectrum_Gratings(basePath, analogin_noVR, lfp_channel, noVR_BL2_Time, tr_ep_no, stim_pos);       
          title('No VR Stim Location: Post baseline trials');
