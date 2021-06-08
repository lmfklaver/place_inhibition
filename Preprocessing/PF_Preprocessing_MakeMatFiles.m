% Preprocessing - run once to make commonly used mat files

%% Split up recording in different parts (Start and stop times of each segment)
% Convert time - referencing recoringInfo.txt
    [Time.Sleep1] = RealTime_Convert_RecordingTime(basePath, 'SleepTime1');
    [Time.Sleep2] = RealTime_Convert_RecordingTime(basePath, 'SleepTime2');
    [Time.Sleep3] = RealTime_Convert_RecordingTime(basePath, 'SleepTime3');
    [Time.Sleep4] = RealTime_Convert_RecordingTime(basePath, 'SleepTime4');
    [Time.VR] = RealTime_Convert_RecordingTime(basePath, 'VRTime');
    [Time.OF] = RealTime_Convert_RecordingTime(basePath, 'OFTime');
    [Time.LT] = RealTime_Convert_RecordingTime(basePath, 'LTTime');
    save([basename '_TimeSegments.analysis.mat'],'Time');
%% Make an analogin just for VR
% Trials from wheel chan - use getWheelTrials (only want wheel trials during VR
% time) AND make an analogin_VR variable that is correct in time
% referencing the recording - VR position and time
    cd(basePath);
    load([basename '_analogin.mat']);
    analogin_VR.pos = analogin.pos(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.blink = analogin.blink(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.ts = analogin.ts(Time.VR.start*30000:Time.VR.stop*30000);
    analogin_VR.sr = analogin.sr;
    save([basename '_analogin_VR.analysis.mat'],'analogin_VR');
    [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin_VR);
    save([basename '_wheelTrials.analysis.mat'],'len_ep','ts_ep','vel_ep','tr_ep','len_ep_fast','ts_ep_fast','vel_ep_fast');
    %[pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin_VR, tr_ep);
%% Split up baseline, stim, and post baseline times
    load([basename '_pulseEpochs.analysis.mat']);
    stimEpochs_VR = pulseEpochs(:,:)> Time.VR.start & pulseEpochs(:,:) < Time.VR.stop;
        pulseEpch.VR(:,1) = pulseEpochs(stimEpochs_VR(:,1));
        pulseEpch.VR(:,2) = pulseEpochs(stimEpochs_VR(:,2));
    stimEpochs_OF = pulseEpochs(:,:)> Time.OF.start & pulseEpochs(:,:) < Time.OF.stop;   
        pulseEpch.OF(:,1) = pulseEpochs(stimEpochs_OF(:,1));
        pulseEpch.OF(:,2) = pulseEpochs(stimEpochs_OF(:,2));
    stimEpochs_LT = pulseEpochs(:,:)> Time.LT.start & pulseEpochs(:,:) < Time.LT.stop;
        pulseEpch.LT(:,1) = pulseEpochs(stimEpochs_LT(:,1));
        pulseEpch.LT(:,2) = pulseEpochs(stimEpochs_LT(:,2));
    save([basename '_pulseEpochs_splitPerSetup.analysis.mat'],'pulseEpch');
%% Split up virtual reality experimental section into prebaseline, stim,
 % and post baseline time 
     %find where first pulse happens
     VR_Stim_First = pulseEpch.VR(1,1);
     VR_Stim_Last = pulseEpch.VR(end,1);
     %tr_ep_all = tr_ep + VR_Time.start; % Liannes
     %ts_ep_all=cellfun(@(x) x+VR_Time.start,ts_ep,'un',0);%Liannes
   
     %find which wheel trials these first and last stims happened in
     VR_Stim_Time.start = tr_ep(find(tr_ep(:,1) < VR_Stim_First & tr_ep(:,2)> VR_Stim_First),1);
     VR_Stim_Time.stop = tr_ep(find(tr_ep(:,1) < VR_Stim_Last & tr_ep(:,2) > VR_Stim_Last),1);
  
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
     clear VR_Stim_First VR_Stim_Last VR_Stim_Trials_idx VR_BL1_Trials_idx VR_BL2_Trials_idx;
     save([basename '_VRTime_BL_Stim.analysis.mat'],'VR_Stim_Time','VR_BL1_Time','VR_BL2_Time','VR_Stim_Trials','VR_BL1_Trials','VR_BL2_Trials');
%% LT and OF trials