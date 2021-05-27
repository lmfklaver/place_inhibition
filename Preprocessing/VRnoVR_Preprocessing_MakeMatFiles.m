%VR No VR Pipeline

%% Split up recording in different parts 
%Convert time - referencing recoringInfo.txt
    [Time.Sleep1] = RealTime_Convert_RecordingTime(basePath, 'SleepTime1');
    [Time.Sleep2] = RealTime_Convert_RecordingTime(basePath, 'SleepTime2');
    [Time.VR] = RealTime_Convert_RecordingTime(basePath, 'VRTime');
    [Time.noVR] = RealTime_Convert_RecordingTime(basePath, 'VRNoTime');
    save([basename '_TimeSegments.analysis.mat'],'Time');
%%
% Trials from wheel chan - use getWheelTrials (only want wheel trials during VR
% time) AND make an analogin_VR variable that is correct in time
% referencing the recording - VR position and time
    cd(basePath);
    load([basename '_analogin.mat']);
    analogin_VR.pos = analogin.pos(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.blink = analogin.blink(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.ts = analogin.ts(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.sr = analogin.sr;
    [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin_VR);
   % [pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin_VR, tr_ep);
    % for noVR
    analogin_noVR.pos = analogin.pos(Time.noVR.start*30000:Time.noVR.stop*30000);
    analogin_noVR.blink = analogin.blink(Time.noVR.start*30000:Time.noVR.stop*30000);
    analogin_noVR.ts = analogin.ts(Time.noVR.start*30000:Time.noVR.stop*30000);
    analogin_noVR.sr = analogin.sr;
    [len_ep_no, ts_ep_no, vel_ep_no, tr_ep_no, len_ep_fast_no, ts_ep_fast_no, vel_ep_fast_no] = getWheelTrials(analogin_noVR);
    save([basename '_analogin_VRnoVR.analysis.mat'],'analogin_VR','analogin_noVR');
    save([basename '_wheelTrials.analysis.mat'],'len_ep','ts_ep','vel_ep','tr_ep','len_ep_fast','ts_ep_fast','vel_ep_fast',...
                               'len_ep_no','ts_ep_no','vel_ep_no','tr_ep_no','len_ep_fast_no','ts_ep_fast_no','vel_ep_fast_no');
   % [pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin_noVR, tr_ep_no);
% Split up baseline, stim, and post baseline times
    load([basename '_pulseEpochs.analysis.mat']);
    stimEpochs_VR = pulseEpochs(:,:)> Time.VR.start & pulseEpochs(:,:) < Time.VR.stop;
        pulseEpch.VR(:,1) = pulseEpochs(stimEpochs_VR(:,1));
        pulseEpch.VR(:,2) = pulseEpochs(stimEpochs_VR(:,2));
    stimEpochs_noVR = pulseEpochs(:,:)> Time.noVR.start & pulseEpochs(:,:) < Time.noVR.stop;   
        pulseEpch.noVR(:,1) = pulseEpochs(stimEpochs_noVR(:,1));
        pulseEpch.noVR(:,2) = pulseEpochs(stimEpochs_noVR(:,2));
    save([basename '_pulseEpochs_splitPerSetup.analysis.mat'],'pulseEpch');
 %%   
 % Split up virtual reality experimental section into prebaseline, stim,
 % and post baseline time 
     %find where first pulse happens in VR
     VR_Stim_First = pulseEpch.VR(1,1);
     VR_Stim_Last = pulseEpch.VR(end,1);
     %find which wheel trials these first and last stims happened in
     VR_Stim_Time.start = tr_ep(find(tr_ep(:,1) < VR_Stim_First & tr_ep(:,2)> VR_Stim_First),1);
     VR_Stim_Time.stop = tr_ep(find(tr_ep(:,1) < VR_Stim_Last & tr_ep(:,2) > VR_Stim_Last),1);
     %find start and stop times of baseline trials and stim trials
     VR_BL1_Time.start = Time.VR.start;
     VR_BL1_Time.stop = VR_Stim_Time.start;
     VR_BL2_Time.start = VR_Stim_Time.stop; 
     VR_BL2_Time.stop = Time.VR.stop;
     VR_BL1_Trials_idx = find(tr_ep(:,1) > VR_BL1_Time.start & tr_ep(:,1) < VR_BL1_Time.stop);
     VR_BL1_Trials = tr_ep(VR_BL1_Trials_idx,:);
     VR_Stim_Trials_idx = find(tr_ep(:,1) > VR_Stim_Time.start & tr_ep(:,1) < VR_Stim_Time.stop);
     VR_Stim_Trials = tr_ep(VR_Stim_Trials_idx,:);  
     VR_BL2_Trials_idx = find(tr_ep(:,1) > VR_BL2_Time.start & tr_ep(:,1) < VR_BL2_Time.stop);
     VR_BL2_Trials = tr_ep(VR_BL2_Trials_idx,:);
    
% Split up no virtual reality into pre baseline, stim, and post baseline
     noVR_Stim_First = pulseEpch.noVR(1,1);
     noVR_Stim_Last = pulseEpch.noVR(end,1);
     %find which wheel trials these first and last stims happened in
     noVR_Stim_Time.start = tr_ep_no(find(tr_ep_no(:,1) < noVR_Stim_First & tr_ep_no(:,2)> noVR_Stim_First),1);
     noVR_Stim_Time.stop = tr_ep_no(find(tr_ep_no(:,1) < noVR_Stim_Last & tr_ep_no(:,2) > noVR_Stim_Last),1);
     %find start and stop times of baseline trials and stim trials
     noVR_BL1_Time.start = Time.noVR.start;
     noVR_BL1_Time.stop = noVR_Stim_Time.start;
     noVR_BL2_Time.start = noVR_Stim_Time.stop; 
     noVR_BL2_Time.stop = Time.noVR.stop;
     noVR_BL1_Trials_idx = find(tr_ep_no(:,1) > noVR_BL1_Time.start & tr_ep_no(:,1) < noVR_BL1_Time.stop);
     noVR_BL1_Trials = tr_ep_no(noVR_BL1_Trials_idx,:);
     noVR_Stim_Trials_idx = find(tr_ep_no(:,1) > noVR_Stim_Time.start & tr_ep_no(:,1) < noVR_Stim_Time.stop);
     noVR_Stim_Trials = tr_ep_no(noVR_Stim_Trials_idx,:);  
     noVR_BL2_Trials_idx = find(tr_ep_no(:,1) > noVR_BL2_Time.start & tr_ep_no(:,1) < noVR_BL2_Time.stop);
     noVR_BL2_Trials = tr_ep_no(noVR_BL2_Trials_idx,:);
% save
    save([basename '_VRTime_BL_Stim.analysis.mat'],'VR_Stim_Time','VR_BL1_Time','VR_BL2_Time','VR_Stim_Trials','VR_BL1_Trials','VR_BL2_Trials',...
        'noVR_Stim_Time','noVR_BL1_Time','noVR_BL2_Time','noVR_Stim_Trials','noVR_BL1_Trials','noVR_BL2_Trials');

