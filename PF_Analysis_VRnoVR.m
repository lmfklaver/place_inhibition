%PF_Analysis_VRnoVR
%% Run Every Time
% Define Recording session path
    basePath = 'F:\Data\VR_noVR\m247\m247_210409_102408';
    basename = bz_BasenameFromBasepath(basePath);
    animalPath = 'F:\Data\AnimalSpecs_ExperimentalParadigms';
% Add paths
    addpath(genpath(basePath));
    addpath(genpath('E:\Reagan\Packages\npy-matlab'));
    addpath(genpath('E:\Reagan\Packages\Kilosort2'));
    addpath(genpath('E:\Reagan\Packages\utilities'));
    addpath(genpath('E:\Reagan\Packages\buzcode'));
    addpath(genpath('E:\Reagan\Packages\TStoolbox'));
    addpath(genpath('E:\Reagan\Code'));
    SetGraphDefaults;

%% Run ONLY Once 
% *DO HAVE TO OPEN* kilosort script in PF_Preprocessing_Pipeline and change path :)

% Run over kilosort, get spikes, lfp, analogin, digitalin, ripples
    PF_Preprocessing_Pipeline
% Make mat analysis files, mat files made by English lab code
    VRnoVR_Preprocessing_MakeMatFiles
% Find State of Sleep
    lfp_chans2check = [10 30 60]; %make sure channels are good ones
    [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(basePath,lfp_chans2check, Time.Sleep1.start, Time.Sleep2.stop);      
    save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
        % sleep
              TheStateEditor(basename, SleepEditorInput)
%% Load Mat Files Commonly Used
    cd([basePath]);
% Load in start and stop times of each sleep and experimental segment
    load([basename '_TimeSegments.analysis.mat']);
    load([basename '_wheelTrials.analysis.mat']);
%% LFP Analysis - Define and Load Mat files
    lfp_channel = 58; %Change this per experiment
    cd([animalPath]);
    load('Maze_Characteristic_Analog_Positions.mat');
    cd([basePath]);
    load([basename '_analogin_VRnoVR.analysis.mat']); %load analogin seperately for VR and no VR segments
%%  LFP Analysis - Power Spec 
% Power Spectra: Compares each setup to previous sleep, also compares all
% sleep parts to all experimental parts in one figure, compares all sleep
% in one figure, compares all experimental parts in one figure
    [IRASA] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Time, 'doLFPClean', false, 'doSplitLFP', false)
    %[runEpochs] = getRunEpochs(basePath, vel_ep);
    save([basename '_IRASA_rz.mat'], 'IRASA');
% Subset of section IRASA - same amount of time 30 min (or specified
% below)
    sub_time_min = 30;%how many minutes to take from each segment
    sub_start_time_min = 20; %how many minutes after sleep to start your sub segment
    Time_sub.Sleep1.start = Sleep1_Time.start + (sub_start_time_min*60);
    Time_sub.Sleep1.stop = Time_sub.Sleep1.start + (sub_time_min*60);
    Time_sub.Sleep2.start = Sleep2_Time.start + (sub_start_time_min*60);
    Time_sub.Sleep2.stop = Time_sub.Sleep2.start + (sub_time_min*60);
    Time_sub.VR.start = VR_Time.start;
    Time_sub.VR.stop = Time_sub.VR.start + (sub_time_min*60);
    Time_sub.noVR.start = noVR_Time.start;
    Time_sub.noVR.stop = Time_sub.noVR.start + (sub_time_min*60);
    [IRASA_subset] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Time_sub, 'doLFPClean', false, 'doSplitLFP', false)
     save([basename '_IRASA_subset_rz.mat'], 'IRASA_subset');
% Velocity Power Spectra: Compares power spectra for VR - for data that has velocity over and under a certain threshold
%fix velocity code, runEpochs work?
    [IRASA_VR_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.VR, 'doLFPClean', false, 'doSplitLFP', false);
    [IRASA_noVR_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.noVR, 'doLFPClean', false, 'doSplitLFP', false);
% Sleep State spectum comparisoin:
%% Velocity analysis
    
    [vel_VR] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
    mean_vel_VR = mean(vel_VR.vel_cm_s);

    [vel_noVR] = getVelocity(analogin_noVR,'circDisk',236, 'doFigure', true);%236cm/unity lap

    [vel] = getVelocity(analogin,'circDisk',236, 'doFigure', true);%236cm/unity lap


    save('Velocity_rz.mat','vel_VR','vel_noVR');

    [runEpochs_VR] = getRunEpochs(basePath, vel_VR);

    [runEpochs_noVR] = getRunEpochs(basePath, vel_noVR);
%% LFP Analysis - WaveSpec - VR
% Get wavespecs around different events - currently stim location, reward
% location, and grating change

% NOTE: Stim location changed from 1.5 to 1.1 on 5/25/21. 
% Experiments BEFORE this date, should use the variable
% 'stim_pos_old' - go into the script and change the input variable to
% such.
    getWavespecsAroundEvents_VR
    

%% LFP Analysis - WaveSpec - NO VR
     getWavespecsAroundEvents_noVR
%% Ripples Analysis
    load([basename '.ripples.analysis.mat']); %or events
% Plot some raw ripples
    subplot(3,3,1)
        plot(lfp_rip.data(round(ripples.timestamps(1,1)*1250):round(ripples.timestamps(1,2)*1250)));
    subplot(3,3,2)
        plot(lfp_rip.data(round(ripples.timestamps(10,1)*1250):round(ripples.timestamps(10,2)*1250)));
    subplot(3,3,3)
        plot(lfp_rip.data(round(ripples.timestamps(100,1)*1250):round(ripples.timestamps(100,2)*1250)));
    subplot(3,3,4)
        plot(lfp_rip.data(round(ripples.timestamps(200,1)*1250):round(ripples.timestamps(200,2)*1250)));
    subplot(3,3,5)
        plot(lfp_rip.data(round(ripples.timestamps(300,1)*1250):round(ripples.timestamps(300,2)*1250)));
    subplot(3,3,6)
        plot(lfp_rip.data(round(ripples.timestamps(400,1)*1250):round(ripples.timestamps(400,2)*1250)));
    subplot(3,3,7)
        plot(lfp_rip.data(round(ripples.timestamps(500,1)*1250):round(ripples.timestamps(500,2)*1250)));
    subplot(3,3,8)
        plot(lfp_rip.data(round(ripples.timestamps(600,1)*1250):round(ripples.timestamps(600,2)*1250)));
    subplot(3,3,9)
        plot(lfp_rip.data(round(ripples.timestamps(700,1)*1250):round(ripples.timestamps(700,2)*1250)));
% Get number of ripples per segment, and the corresponding start and stop
% times of the specific ripples
    [rippleTimestamps.sleep1] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.Sleep1);
    [numRipples.sleep1, rippleLength.sleep1] = getNumAndLength_Ripples(rippleTimestamps.sleep1);
    
    [rippleTimestamps.sleep2] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.Sleep2);
    [numRipples.sleep2, rippleLength.sleep2] = getNumAndLength_Ripples(rippleTimestamps.sleep2);
    
    [rippleTimestamps.VR] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.VR);
    [numRipples.VR, rippleLength.VR]         = getNumAndLength_Ripples(rippleTimestamps.VR);
    
    [rippleTimestamps.noVR] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.noVR);
    [numRipples.noVR, rippleLength.noVR]         = getNumAndLength_Ripples(rippleTimestamps.noVR);

% Make box plot of ripple length per segment  
    % Experimental Segments
        ripLengthExp = [rippleLength.VR;rippleLength.noVR];
        groupLength.VR = repmat({'VR'},length(rippleLength.VR),1);
        groupLength.noVR = repmat({'noVR'},length(rippleLength.noVR),1);
        ripLengthExpGroup = [groupLength.VR; groupLength.noVR];
        figure;
        boxplot(ripLengthExp, ripLengthExpGroup);% rippleLength.sleep2])
        hold on
        ylabel('Ripple Length (s)')
        title('Ripple length of experimental segments')
    % Sleep Segments
        ripLengthSleep = [rippleLength.sleep1;rippleLength.sleep2; rippleLength.sleep3;rippleLength.sleep4];
        groupLength.sleep1 = repmat({'Sleep 1'},length(rippleLength.sleep1),1);
        groupLength.sleep2 = repmat({'Sleep 2'},length(rippleLength.sleep2),1);
        ripLengthSleepGroup = [groupLength.sleep1; groupLength.sleep2];
        figure;
        boxplot(ripLengthSleep, ripLengthSleepGroup);% rippleLength.sleep2])
        hold on;
        ylabel('Ripple Length (s)');
        title('Ripple length of sleep segments');
  
% Make a Plot comparing number of ripples/time in that segment (could add
% movement vs not movement?)
        %[vel] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
        %[run] = getRunEpochs(basePath, vel);
        %[no_run] = getNoRunEpochs(run);
        subplot(1,2,1);
        warm_colors = hot(20); %3,7,10,12
        cool_colors = cool(20);%3, 7, 11, 18
        plot(1, numRipples.sleep1,'o','Color',warm_colors(3,:));
        hold on;
        plot(1, numRipples.sleep2,'o','Color',warm_colors(7,:));
        xlim([0 2]);
        legend({'Sleep 1','Sleep 2'});
        ylabel('Number of Ripples');
       subplot(1,2,2)
        plot(1, numRipples.VR,'o','Color',cool_colors(3,:));
        hold on;
        plot(1, numRipples.noVR,'o','Color',cool_colors(7,:));
        xlim([0 2]);
        legend({'VR','no VR'});
        ylabel('Number of Ripples');
 %% ripple distributions for singular session
% Make a plot comparing ripple length distribution between different sleep
% segments (chunks of all sleep)
        Time_sleep_sessions(1,1) = Time.Sleep1.start;
        Time_sleep_sessions(1,2) = Time.Sleep1.stop;
        Time_sleep_sessions(2,1) = Time.Sleep2.start;
        Time_sleep_sessions(2,2) = Time.Sleep2.stop;
        subplot(2,2,1);
        getRippleDurationDistribution_SpecificSleepState(Time_sleep_sessions, Time, ripples);
        title({'Ripple length per sleep session',[basename]});
% Make a plot comparing ripple length distribution between different sleep
% segments only NREM ripples (only NREM
        subplot(2,2,2);
        getRippleDurationDistribution_SpecificSleepState(SleepState.ints.NREMstate, Time, ripples);
        title({'NREM Ripple length per sleep session',[basename]}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only REM ripples (only REM)
        subplot(2,2,3);
         getRippleDurationDistribution_SpecificSleepState(SleepState.ints.REMstate, Time, ripples);
        title({'REM Ripple length per sleep session',[basename]}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only Wake ripples (Only awake)
        subplot(2,2,4);
        getRippleDurationDistribution_SpecificSleepState(SleepState.ints.WAKEstate, Time, ripples);
        title({'WAKE Ripple length per sleep session',[basename]}); 
%% Ripples across sessions (section loads all sessions in directory, and calculates the ripple rate during NREM sleep, plots it on a figure)
% load all the sessions we want to compare
    RecordingDirectory_PlaceTuning
    
    figure(1);
    rippleRateFig = axes;
    figure(2);
    timeNREMFig = axes;
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3,7,10,12
    color_all = [warm_colors(3,:);cool_colors(3,:);warm_colors(7,:);cool_colors(7,:);warm_colors(10,:);cool_colors(10,:);warm_colors(12,:);cool_colors(12,:)];
    for irec = 1:length(recDir)
        % load in the ripple file for this directory ( if does not exist -
        % create it)
             cd(recDir{irec});
             basePath = cd;
             basename = bz_BasenameFromBasepath(basePath);
             if ~isfile([basename '_TimeSegments.analysis.mat'])
                    [Time.Sleep1] = RealTime_Convert_RecordingTime(cd, 'SleepTime1');
                    [Time.Sleep2] = RealTime_Convert_RecordingTime(cd, 'SleepTime2');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.noVR] = RealTime_Convert_RecordingTime(cd, 'VRNoTime');
                    save([basename '_TimeSegments.analysis.mat'],'Time');
             end
             load([basename '_TimeSegments.analysis.mat']);
             if ~isfile([basename '.ripples.events.mat'])
            	 PF_Preprocessing_Ripples 
             end
             load([basename '.ripples.events.mat']);
         % load in the sleep state mat (if does not exist - create it)
             if ~isfile([basename '_SleepState.analysis.mat'])
                 lfp_chans2check = [10 30 60]; %make sure channels are good ones
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep2.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
             end 
             load([basename '_SleepState.analysis.mat']);
         % load in ripples NREM for Sleep1,2,3,4 individaully
            % split NREM segments into each sleep segment
              [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
              [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
             % find how many ripples happen in each segment
                 % Sleep 1
                    [NREM_sleep1_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep1_intervals);
                    NREM_S1_ripples = ripples.timestamps(NREM_sleep1_logical,:);
                    [numRipples_NREM.S1,rippleLength_NREM.S1] = getNumAndLength_Ripples(NREM_S1_ripples);
                 % Sleep 2
                    [NREM_sleep2_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep2_intervals);
                    NREM_S2_ripples = ripples.timestamps(NREM_sleep2_logical,:);
                    [numRipples_NREM.S2,rippleLength_NREM.S2] = getNumAndLength_Ripples(NREM_S2_ripples);
              % Find total time in each sleep NREM
                    NREM_TotalTime.S1 = sum(NREM_sleep1_intervals(:,2)-NREM_sleep1_intervals(:,1));
                    NREM_TotalTime.S2 = sum(NREM_sleep2_intervals(:,2)-NREM_sleep2_intervals(:,1));
            % Plot ripple rate for each sleep segment
                    plot(rippleRateFig,1, (numRipples_NREM.S1/NREM_TotalTime.S1), 'o','Color',color_all(irec,:));
                    hold(rippleRateFig,'on');
                    plot(rippleRateFig,2, (numRipples_NREM.S2/NREM_TotalTime.S2), 'o','Color',color_all(irec,:));
                    % save in mat
                    rippleRateMat(irec,1) = numRipples_NREM.S1/NREM_TotalTime.S1;
                    rippleRateMat(irec,2) = numRipples_NREM.S2/NREM_TotalTime.S2;
                   
            % Plot length of NREM for each sleep segment on a different
            % plot
              
                    plot(timeNREMFig,1, NREM_TotalTime.S1, 'o', 'Color',color_all(irec,:));
                    hold(timeNREMFig, 'on');
                    plot(timeNREMFig,2, NREM_TotalTime.S2, 'o', 'Color',color_all(irec,:));
                  
                    totalTimeMat(irec,1) = NREM_TotalTime.S1;
                    totalTimeMat(irec,2) = NREM_TotalTime.S2;
                  
                    
    end
                    title(rippleRateFig, 'Ripple Rate per sleep session');
                    xlabel(rippleRateFig,'Sleep Session');
                    ylabel(rippleRateFig,'Ripple Rate (ripples/sec)');
                    xlim(rippleRateFig,[0 5]);
                    ylim(rippleRateFig,[0 1]);
                    
                    title(timeNREMFig,'Total NREM Time per sleep session');
                    xlabel(timeNREMFig,'Sleep Session');
                    ylabel(timeNREMFig,'Time (s)');
                    xlim(timeNREMFig,[0 5]);
             % Make subplot of Ripple Rate and Total Time spent in sleep
                    figure;
                    subplot(1,2,1);
                    boxplot(rippleRateMat);
                    title('NREM Ripple Rate');
                    xlabel('Sleep Session');
                    ylabel('NREM Ripple Rate (ripples/s)');
                    subplot(1,2,2);
                    boxplot(totalTimeMat);
                    title('Total NREM Time');
                    xlabel('Sleep Session');
                    ylabel('Time (s)');
%% Firing Rate across sessions
    %      firing per cell per exp segment (each box a different day)
    %            3 boxes per day, (each task is a different color)
    % chunk whole segment?
% compare time in day and by session
    RecordingDirectory_PlaceTuning
    %sleep 1 rem and nrem
    figure(1);
    firingRateFig = axes;
    figure(2);
    firingRateExp = axes;
    warm_colors = hot(20); %3,7,10,12
    color_all = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];
    cool_colors = cool(20);
    exp_colors = [cool_colors(3,:); cool_colors(7,:); cool_colors(11,:)];
    rec_num = 0; %counter for how many recordings in directory have spikes
     X1=[1,3,5,7,9,11,13,15];
     X2=[1.3 3.3 5.3 7.3 9.3 11.3 13.3 15.3];
     X3=[1.6 3.6 5.6 7.6 9.6 11.6 13.6 15.6];
     X4=[1.9 3.9 5.9 7.9 9.9 11.9 13.9 15.9];
     
    for irec = 1:length(recDir)
        % load in the ripple file for this directory ( if does not exist -
        % create it)
             cd(recDir{irec});
             basePath = cd;
             basename = bz_BasenameFromBasepath(basePath);
             if ~isfile([basename '_TimeSegments.analysis.mat'])
                    [Time.Sleep1] = RealTime_Convert_RecordingTime(cd, 'SleepTime1');
                    [Time.Sleep2] = RealTime_Convert_RecordingTime(cd, 'SleepTime2');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.noVR] = RealTime_Convert_RecordingTime(cd, 'VRNoTime');       
                    save([basename '_TimeSegments.analysis.mat'],'Time');
             end
             load([basename '_TimeSegments.analysis.mat']);
       % load in spiking info
             if ~isfile([basename '.spikes.cellinfo.mat']);
                     continue; %need to get spikes before doing this
             else
                 rec_num = rec_num +1;
             end
             load([basename '.spikes.cellinfo.mat']);
        % load in the sleep state mat (if does not exist - create it)
             if ~isfile([basename '_SleepState.analysis.mat'])
                 lfp_chans2check = [10 30 60]; %make sure channels are good ones
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
             end 
             load([basename '_SleepState.analysis.mat']);
       % find nrem and rem intervals (sleep times)
            [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
            [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
            [REM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
            [REM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
          
            
       % put NREM and REM intervals together for one sleep session
             sleep1_intervals = [NREM_sleep1_intervals;REM_sleep1_intervals];
             sleep2_intervals = [NREM_sleep2_intervals;REM_sleep2_intervals];
            
       % total time of each sleep interval
             SleepTotalTime.S1 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
             SleepTotalTime.S2 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));

       % find how many spikes there are in each segment;
             sleep_FR_mat = zeros(length(spikes.times),4);
             exp_FR_mat = zeros(length(spikes.times),3);
             % for each cell, find the spike times within each sleep
             % interval and within each task interval
             for icell = 1:length(spikes.times)
                    [sleep_FR_mat(icell,1)] = getFiringRate(sleep1_intervals, spikes.times{icell});
                    [sleep_FR_mat(icell,2)] = getFiringRate(sleep2_intervals, spikes.times{icell});
                    [exp_FR_mat(icell,1)] = getFiringRate([Time.VR.start Time.VR.stop],spikes.times{icell});
                    [exp_FR_mat(icell,2)] = getFiringRate([Time.noVR.start Time.noVR.stop],spikes.times{icell});
                
             end
       % boxplot sleep
    
            boxplot(firingRateFig, sleep_FR_mat(:,1),'positions',X1(irec),'labels',X1(irec),'colors',color_all(1,:),'widths',0.25);
            hold(firingRateFig, 'on');
            boxplot(firingRateFig,sleep_FR_mat(:,2),'positions',X2(irec),'labels',X2(irec),'colors',color_all(2,:),'widths',0.25);
            title(firingRateFig,'Firing Rate For Sleep Sessions')
            xticks(firingRateFig,X1(1:length(recDir)));
            ylabel(firingRateFig, 'Firing Rate (spikes/s)');
            legend(firingRateFig, findall(gca,'Tag','Box'), {'Sleep 1','Sleep 2'});
            ylim([0 20]);
            
            boxplot(firingRateExp, exp_FR_mat(:,1),'positions',X1(irec),'labels',X1(irec),'colors',exp_colors(1,:),'widths',0.25);
            hold(firingRateExp, 'on');
            boxplot(firingRateExp, exp_FR_mat(:,2),'positions',X2(irec),'labels',X2(irec),'colors',exp_colors(2,:),'widths',0.25);
            title(firingRateExp, 'Firing Rate For Experimental Sessions')
            xticks(firingRateExp, X1(1:length(recDir)));
            ylabel(firingRateExp, 'Firing Rate (spikes/s)');
            hLegend = legend(firingRateExp,findall(gca,'Tag','Box'), {'VR','no VR'});
            ylim([0 20]);
    end

%% Spiking Analysis - Define and load mat files
    cd([basePath]);
    load([basename '.spikes.cellinfo.mat']);
    load([basename '.cell_metrics.cellinfo.mat']);
    load([basename '_pulseEpochs_splitPerSetup.analysis.mat']);
    cell_idx = 1;
    exper_paradigm = 'VR'; 
    pulseEpochs_exper = pulseEpch.VR; 
    trial_exper = tr_ep; %trial start and stop times for exper
%% Spiking Analysis - Single Cell Characteristics for one Unit
% Creates a group of plots about one cell: autocorrelations in and out of
% pulse for specified experiment, raw waveform,raster, and PETH around pulse

% Plot raw waveform
     subplot(3,2,1);
     plot(.195*spikes.rawWaveform{cell_idx});
     xlabel('Time (ms)');
     ylabel('Amplitude (uV)');
     xticks([0 20 40 60 80 100 120 140]);
     xticklabels({'0','1','2','3','4','5','6','7'})
     title(['Cell ' num2str(cell_idx) ':Raw Waveform']);
     box off;
     axis square;
% Spike count Plot around opto stim
     subplot(3,2,3);
     getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, cell_idx)
% Plot raster over cell for each trial - need to align to pulses
    subplot(3,2,4);
    getRasterPlots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, cell_idx);  
% Plot CCG
     [ccginout] = getCCGinout(basePath, spikes.times, pulseEpochs_exper); %I changed this function to have spikes as an input\
     if ccginout.ccgIN >0
        subplot(3,2,5);
        plot(ccginout.ccgIN(:,cell_idx, cell_idx)); %in pulse
        title('CCG In Pulse');
        xlabel('Time(ms)');
        ylabel('Correlation');
        axis square;
     end
     if ccginout.ccgOUT > 0
        subplot(3,2,6);
        plot(ccginout.ccgOUT(:,cell_idx, cell_idx));  %out of pulse
        axis square;
        title('CCG Out Pulse');
        xlabel('Time(ms)');
        ylabel('Correlation');
        axis square;
     end     
%% Spiking Analysis - Single Cell characteristics for all units
% Gets out PETH and Raster around stim for each cell and saves each to a
% figure. Also calculate auto corr and cross corr for each cell and saves
% to pdf.

% Group all Interneurons and Pyramidal cells together (get indexes of each
% cell type)
    IN_count = 1;
    PYR_count = 1;
    for icell = 1:length(spikes.times)
        if (cell_metrics.putativeCellType{icell}(1:4) == 'Narr')
            IN_Cell(1,IN_count) = icell;
            IN_count = IN_count+1;
        elseif (cell_metrics.putativeCellType{icell}(1:4) == 'Pyra')
            PYR_Cell(1,PYR_count) = icell;
            PYR_count = PYR_count+1;
        end
    end
% Make a figure for each Interneuron: plot of PETH and Raster around stim
    for iUnit = 1:length(IN_Cell)
        fig = figure,
        % PSTH of one cell around opto stim time (can specify which pulses)
        subplot(2,1,1)
        getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm,IN_Cell(iUnit)) %'runAllInterneurons', True);
        % Plot Raster of one cell around opto stim time (can specify which pulses)
        subplot(2,1,2)
        getRasterPlots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, IN_Cell(iUnit));
        % Plot autocorrelation of specified cell inside and outside opto stim
        % epochs
        cd([basePath '\Figures\OptoStim'])
        savefig(cd,['Raster/PETH IN Cell: ' num2str(IN_Cell(iUnit)]);
        delete(fig);
    end
% Make a figure for each Pyramidal cell: plot of PETH and Raster around stim
    for iUnit = 1:length(PYR_Cell)
        fig = figure,
        % PSTH of one cell around opto stim time (can specify which pulses)
        subplot(2,1,1)
        getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm,PYR_Cell(iUnit)) %'runAllInterneurons', True);
        % Plot Raster of one cell around opto stim time (can specify which pulses)
        subplot(2,1,2)
        getRasterPlots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, PYR_Cell(iUnit));
        % Plot autocorrelation of specified cell inside and outside opto stim
        % epochs
        cd([basePath '\Figures\OptoStim'])
        savefig(cd,['Raster/PETH PYR Cell: ' num2str(PYR_Cell(iUnit)]);
        delete(fig);
    end
    cd(basePath);
    
% CCG: Auto corr in black and cross corr in blue (for each neuron a
% different figure)saved to a pdf
    ccg = ccginout.ccgOUT;
    t = ccginout.t;   
        for iUnit = 1:size(ccg,2)
            numPanels = ceil(sqrt(size(ccg,2)));
            
            figure
            set(gcf,'Position',[50 50 1200 800]);
            set(gcf,'PaperOrientation','landscape');
            
            for nPlot = 1:size(ccg,3)
                subplot(numPanels,numPanels,nPlot)
                if iUnit == nPlot
                    bar(t,ccg(:,iUnit,nPlot),'k')
                else
                    bar(t,ccg(:,iUnit,nPlot))
                end
                title(num2str(spikes.cluID(nPlot)));
            end
             unitStr = [basePath '\Figures\' num2str(iUnit)];
             savefig(gcf,[unitStr '.fig'])
             print(gcf,[unitStr '.pdf'],'-dpdf','-bestfit')
            append_pdfs([basePath '\Figures\allCCG.pdf'],[unitStr '.pdf'])
            delete([unitStr '.pdf'])
            close gcf
        end
%% Virtual Reality - Load and define
    icell_idx = 1;
    load('m247_210421_083423.spikes.cellinfo.mat');
    load('m247_210421_083423_analogin_VR.analysis.mat');
    
        %% Virtual Reality - Place Fields
%sanity check - do not quite get how
%     [SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin_VR, spikes)
%     plot(SpkTime{2}, SpkVoltage{2})
    
% Get the corresponding voltage position of each spike timestamp
      [spkEpVoltIdx] = getWheelPositionPerSpike(basePath, tr_ep);
% Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin) **FIGURE OUT CM OF TRACK VR*
      [fig, fr_position] = getPlaceField_VR(basePath, cell_idx, spkEpVoltage, tr_ep, len_ep, ts_ep, analogin_VR);
% Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)
      getPopulationPlaceField_VR(basePath, tr_ep_all, len_ep, ts_ep_all, spikes, analogin_VR)
       
 % Colorful Raster of all cells over position (y trials, x position) dots different color for
 % different cells
    getRasterOverPosition(spikes, VR_BL1_Trials);
    getRasterOverPosition(spikes, VR_VR_Trials);
    getRasterOverPosition(spikes, VR_BL2_Trials);
