%PF_Analysis_AllSetups
%For LT, VR, OF 
%% Set Paths
    basePath = 'F:\Data\PlaceTuning_VR_OF_LT\m247\m247_210421_083423';
    %basePath = 'F:\Data\PlaceTuning_VR_OF_LT\m246\m246_210607_081650';
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
    addpath('F:\Data\PlaceTuning_VR_OF_LT') %has directory of all sessions
    SetGraphDefaults;
%% Run ONLY Once 
% *DO HAVE TO OPEN* PF_Preprocessing_Pipeline and change path :)
%                  1) change path in kilosort
%                  2) Might want to look at rip file in neuroscope to see
%                  if ripples are being detected well

% Run over kilosort, get spikes, lfp, analogin, digitalin, ripples
    PF_Preprocessing_Pipeline
% Make mat analysis files, mat files made by English lab code
    PF_Preprocessing_MakeMatFiles
% Ripples
    PF_Preprocessing_Ripples %if get error, make sure your text recording info file has 'Max Ripple Channel' set to a number (chosen by eye)
% Validate Sleep (can put part of this is in the script above if want to -
% after troubleshooting is over)
    lfp_chans2check = [10 30 60]; %make sure channels are good ones
    [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(basePath,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
    save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
        % sleep
              TheStateEditor(basename, SleepEditorInput)
%% Load Mat Files Commonly Used
    cd([basePath]);
% Load in start and stop times of each sleep and experimental segment
    load([basename '_TimeSegments.analysis.mat']);
    load([basename '_wheelTrials.analysis.mat']);
%% LFP Analysis - Define and Load Mat files
    load([basneame '_ripples.analysis.mat']);
    lfp_channel = ripples.detectorinfo.detectionchannel; %0 based
    cd([animalPath]);
    load('Maze_Characteristic_Analog_Positions.mat');
    cd([basePath]);
    load([basename '_analogin_VR.analysis.mat']);
%%  LFP Analysis - Power Spectra
% Power Spectra without fractals: Compares each setup to previous sleep, also compares all
% sleep parts to all experimental parts in one figure, compares all sleep
% in one figure, compares all experimental parts in one figure
    [IRASA] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time, 'doLFPClean', false, 'doSplitLFP', false)
    %[runEpochs] = getRunEpochs(basePath, vel_ep);
    save([basename '_IRASA.analysis.mat'], 'IRASA');
% Subset of section IRASA - same amount of time 30 min (or specified
% below)
    sub_time_min = 30;%how many minutes to take from each segment
    sub_start_time_min = 20; %how many minutes after sleep to start your sub segment
    Time_sub.Sleep1.start = Time.Sleep1.start + (sub_start_time_min*60);
    Time_sub.Sleep1.stop = Time_sub.Sleep1.start + (sub_time_min*60);
    Time_sub.Sleep2.start = Time.Sleep2.start + (sub_start_time_min*60);
    Time_sub.Sleep2.stop = Time_sub.Sleep2.start + (sub_time_min*60);
    Time_sub.Sleep3.start = Time.Sleep3.start + (sub_start_time_min*60);
    Time_sub.Sleep3.stop = Time_sub.Sleep3.start + (sub_time_min*60);
    Time_sub.Sleep4.start = Time.Sleep4.start + (sub_start_time_min*60);
    Time_sub.Sleep4.stop = Time_sub.Sleep4.start + (sub_time_min*60);
    Time_sub.VR.start = Time.VR.start;
    Time_sub.VR.stop = Time_sub.VR.start + (sub_time_min*60);
    Time_sub.LT.start = Time.LT.start;
    Time_sub.LT.stop = Time_sub.LT.start + (sub_time_min*60);
    Time_sub.OF.start = Time.OF.start;
    Time_sub.OF.stop = Time_sub.OF.start + (sub_time_min*60);
    
    [IRASA_subset] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time_sub, 'doLFPClean', false, 'doSplitLFP', false)
    %[runEpochs] = getRunEpochs(basePath, vel_ep);
    save([basename '_IRASA_sub.analysis.mat'], 'IRASA_subset');
    
% Velocity Power Spectra: Compares power spectra for VR - for data that has velocity over and under a certain threshold
%fix velocity code, runEpochs work?
    [IRASA_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.VR, 'doLFPClean', false, 'doSplitLFP', false);
% Sleep Spectrum NREM REM
    load([basename '_SleepState.analysis.mat']);
    % only does sleep1 and sleep 2 right now (for VR)
    [IRASA_SleepState] = getPowerSpectrum_SleepState(basePath, lfp_channel, Time, SleepState,'doLFPClean',false,'doSplitLFP',false);
    save([basename '_IRASA_SleepState.analysis.mat'],'IRASA_SleepState');
%% LFP Analysis - Power Spec over many recordings
% this script requires you to have each session you want to look at already
% ran over the getPowerSpectrum_PlaceInhibition Script
    % Run the script with all the recordings paths you want to look at
    RecordingDirectory_PlaceTuning
    % Plot the std error shaded power spectrum
    getStdErrorPowerSpectra(recDir)
%% LFP Analysis - PowerSpectra and Wavespec for specified periods
% Get wavespecs around different events - currently stim location, reward
% location, and grating change

% NOTE: Stim location changed from 1.5 to 1.1 on 5/25/21. 
% Experiments BEFORE this date, should use the variable
% 'stim_pos_old' - go into the script and change the input variable to
% such.
    getWavespecsAroundEvents_VR
%% Ripples Analysis
    load([basename '.ripples.analysis.mat']);
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
    
    [rippleTimestamps.sleep3] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.Sleep3);
    [numRipples.sleep3, rippleLength.sleep3] = getNumAndLength_Ripples(rippleTimestamps.sleep3);
    
    [rippleTimestamps.sleep4] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.Sleep4);
    [numRipples.sleep4, rippleLength.sleep4] = getNumAndLength_Ripples(rippleTimestamps.sleep4);
    
    [rippleTimestamps.VR] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.VR);
    [numRipples.VR, rippleLength.VR]         = getNumAndLength_Ripples(rippleTimestamps.VR);
    
    [rippleTimestamps.OF] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.OF);
    [numRipples.OF, rippleLength.OF]         = getNumAndLength_Ripples(rippleTimestamps.OF);
    
    [rippleTimestamps.LT] = getIntervals_InBiggerIntervals(ripples.timestamps,Time.LT);
    [numRipples.LT, rippleLength.LT]         = getNumAndLength_Ripples(rippleTimestamps.LT);
% Make box plot of ripple length per segment  
    % Experimental Segments
        ripLengthExp = [rippleLength.VR;rippleLength.LT; rippleLength.OF];
        groupLength.VR = repmat({'VR'},length(rippleLength.VR),1);
        groupLength.LT = repmat({'LT'},length(rippleLength.LT),1);
        groupLength.OF = repmat({'OF'},length(rippleLength.OF),1);
        ripLengthExpGroup = [groupLength.VR; groupLength.LT; groupLength.OF];
        figure;
        boxplot(ripLengthExp, ripLengthExpGroup);% rippleLength.sleep2])
        hold on
        ylabel('Ripple Length (s)')
        title('Ripple length of experimental segments')
    % Sleep Segments
        ripLengthSleep = [rippleLength.sleep1;rippleLength.sleep2; rippleLength.sleep3;rippleLength.sleep4];
        groupLength.sleep1 = repmat({'Sleep 1'},length(rippleLength.sleep1),1);
        groupLength.sleep2 = repmat({'Sleep 2'},length(rippleLength.sleep2),1);
        groupLength.sleep3 = repmat({'Sleep 3'},length(rippleLength.sleep3),1);
        groupLength.sleep4 = repmat({'Sleep 4'},length(rippleLength.sleep4),1);
        ripLengthSleepGroup = [groupLength.sleep1; groupLength.sleep2; groupLength.sleep3; groupLength.sleep4];
        figure;
        boxplot(ripLengthSleep, ripLengthSleepGroup);% rippleLength.sleep2])
        hold on
        ylabel('Ripple Length (s)')
        title('Ripple length of sleep segments')
% Make a Plot comparing number of ripples/time in that segment (could add
% movement vs not movement?)
        %[vel] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
        %[run] = getRunEpochs(basePath, vel);
        %[no_run] = getNoRunEpochs(run);
        subplot(1,2,1)
        warm_colors = hot(20); %3,7,10,12
        cool_colors = cool(20);%3, 7, 11, 18
        plot(1, numRipples.sleep1,'o','Color',warm_colors(3,:));
        hold on
        plot(1, numRipples.sleep2,'o','Color',warm_colors(7,:));
        plot(1, numRipples.sleep3,'o','Color',warm_colors(10,:));
        plot(1, numRipples.sleep4,'o','Color',warm_colors(12,:));
        xlim([0 2])
        legend({'Sleep 1','Sleep 2','Sleep 3','Sleep 4'});
        ylabel('Number of Ripples')
       subplot(1,2,2)
        plot(1, numRipples.VR,'o','Color',cool_colors(3,:));
        hold on
        plot(1, numRipples.LT,'o','Color',warm_colors(7,:));
        plot(1, numRipples.OF,'o','Color',warm_colors(11,:));
        xlim([0 2])
        legend({'VR','LT','OF'});
        ylabel('Number of Ripples')
% comparing long ripples vs short ones
%% Ripples across sessions (section loads all sessions in directory, and calculates the ripple rate during NREM sleep, plots it on a figure)
% load all the sessions we want to compare
    RecordingDirectory_PlaceTuning
    
    rippleRateFig = figure;
    timeNREMFig  = figure;
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
                    [Time.Sleep3] = RealTime_Convert_RecordingTime(cd, 'SleepTime3');
                    [Time.Sleep4] = RealTime_Convert_RecordingTime(cd, 'SleepTime4');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.OF] = RealTime_Convert_RecordingTime(cd, 'OFTime');
                    [Time.LT] = RealTime_Convert_RecordingTime(cd, 'LTTime');
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
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
             end 
             load([basename '_SleepState.analysis.mat']);
         % load in ripples NREM for Sleep1,2,3,4 individaully
            % split NREM segments into each sleep segment
              [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
              [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
              [NREM_sleep3_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep3);
              [NREM_sleep4_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep4);
             % find how many ripples happen in each segment
                 % Sleep 1
                    [NREM_sleep1_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep1_intervals);
                    NREM_S1_ripples = ripples.timestamps(NREM_sleep1_logical,:);
                    [numRipples_NREM.S1,rippleLength_NREM.S1] = getNumAndLength_Ripples(NREM_S1_ripples);
                 % Sleep 2
                    [NREM_sleep2_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep2_intervals);
                    NREM_S2_ripples = ripples.timestamps(NREM_sleep2_logical,:);
                    [numRipples_NREM.S2,rippleLength_NREM.S2] = getNumAndLength_Ripples(NREM_S2_ripples);
                 % Sleep 3
                    [NREM_sleep3_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep3_intervals);
                    NREM_S3_ripples = ripples.timestamps(NREM_sleep3_logical,:);
                    [numRipples_NREM.S3,rippleLength_NREM.S3] = getNumAndLength_Ripples(NREM_S3_ripples);
                 % Sleep 4
                    [NREM_sleep4_logical, ~, ~] = InIntervals(ripples.timestamps,  NREM_sleep4_intervals);
                    NREM_S4_ripples = ripples.timestamps(NREM_sleep4_logical,:);
                    [numRipples_NREM.S4,rippleLength_NREM.S4] = getNumAndLength_Ripples(NREM_S4_ripples);
              % Find total time in each sleep NREM
                    NREM_TotalTime.S1 = sum(NREM_sleep1_intervals(:,2)-NREM_sleep1_intervals(:,1))
                    NREM_TotalTime.S2 = sum(NREM_sleep2_intervals(:,2)-NREM_sleep2_intervals(:,1))
                    NREM_TotalTime.S3 = sum(NREM_sleep3_intervals(:,2)-NREM_sleep3_intervals(:,1))
                    NREM_TotalTime.S4 = sum(NREM_sleep4_intervals(:,2)-NREM_sleep4_intervals(:,1))
            % Plot ripple rate for each sleep segment
                    plot(rippleRateFig, 1, (numRipples_NREM.S1/NREM_TotalTime.S1), '.','Color',color_all(irec,:));
                    hold on
                    plot(rippleRateFig, 2, (numRipples_NREM.S2/NREM_TotalTime.S2), '.','Color',color_all(irec,:));
                    plot(rippleRateFig, 3, (numRipples_NREM.S3/NREM_TotalTime.S3), '.','Color',color_all(irec,:));
                    plot(rippleRateFig, 4, (numRipples_NREM.S4/NREM_TotalTime.S4), '.','Color',color_all(irec,:));
            % Plot length of NREM for each sleep segment on a different
            % plot
                    plot(timeNREMFig, 1, NREM_TotalTime.S1, '.', 'Color',color_all(irec,:));
                    hold on
                    plot(timeNREMFig, 2, NREM_TotalTime.S2, '.', 'Color',color_all(irec,:));
                    plot(timeNREMFig, 3, NREM_TotalTime.S3, '.', 'Color',color_all(irec,:));
                    plot(timeNREMFig, 4, NREM_TotalTime.S4, '.', 'Color',color_all(irec,:));
    end
                    title(rippleRateFig, 'Ripple Rate per sleep session');
                    xlabel('Sleep Sessoin')
                    ylabel('Ripple Rate (ripples/sec)'
                  
    
%% Spiking Analysis - Define and load mat files
    cd([basePath]);
    load([basename '.spikes.cellinfo.mat']);
    load([basename '.cell_metrics.cellinfo.mat']);
    load([basename '_pulseEpochs_splitPerSetup.analysis.mat']);
    cell_idx = 1;
    exper_paradigm = 'VR'; %'LT' 'OF'
    pulseEpochs_exper = eval(['pulseEpch.' num2str(exper_paradigm)]);
    trial_exper = tr_ep; %trial start and stop times for exper
%% Firing Rate across sessions
    % chunk in bins and show over time?
    % chunk in bins and box plot for different segments
    % chunk whole segment?


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
        savefig(cd,['Raster/PETH IN Cell: ' num2str(IN_Cell(iUnit))]);
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
        savefig(['Raster/PETH PYR Cell: ' num2str(PYR_Cell(iUnit))]);
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
    icell = 1;
    load('m247_210421_083423.spikes.cellinfo.mat');
    load('m247_210421_083423_analogin_VR.analysis.mat');
    
%% Virtual Reality Place Fields
  %position at begging of maze = 2.5
  % water reward (voltage drop) = .8
   
% Get the corresponding voltage position of each spike timestamp
      [spkEpVoltIdx, spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep);
% Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin)
      [fig, fr_position] = getPlaceField_VR(basePath, icell, spkEpVoltage, tr_ep, len_ep, ts_ep, analogin_VR);
      savefig(['Cell' num2str(icell) '_PlaceField.fig'])
      delete(fig);

% Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)
    getPopulationPlaceField_VR(basePath, tr_ep, len_ep, ts_ep, spikes, analogin_VR)
         
 % Colorful Raster of all cells over position (y trials, x position) dots different color for
 % different cells
    getRasterOverPosition(spikes, VR_BL1_Trials);
    getRasterOverPosition(spikes, VR_VR_Trials);
    getRasterOverPosition(spikes, VR_BL2_Trials);
        
%% Videos with spiking on top
    % NEED: correct spike times to be in line video start time
        % currently: subtracting start time of open field from spikes to
        % correct for time
    %Note: the video may blink, if a position is not detected by bonsai
    %(the model failed to pick up location for that point)
    
    
    % Two ways to assign position to different spikes
            % 1) bin the spikes in 1 ms bins
            %    calculate how many bins per frame
            %    count how many spikes fall into each bin
            %    if more than one spike, make it equal to one
            % 2) get the position times outputted from bonsai (should
            %      match up with the position estimate locations)
            %    find the corresponding bin for each spike (spike < bin
            %    stop and spike > bin start, this is the position of the
            %    animal then)
    cell_idx = 1; %define what cell to map
    OF_SingleCell_Video
    
    %Plot each cell spikes in open field 
    for cell_idx = 1:length(spikes.times)
    % Plot of cell firing in open field
        positionEstimate_file = csvread([basename(1:12) 'PositionEstimate.csv']);
        x_pos = positionEstimate_file(:,1);
        x = x_pos + conversion_add2Exp;
        y_pos = positionEstimate_file(:,2);
        y = y_pos + conversion_add2Exp;
        fid = fopen([basename(1:12) 'PositionTimestamps.csv']);
        C = textscan(fid,'%s','HeaderLines',8,'Delimiter',',','EndOfLine','\r\n','ReturnOnError',false);
        fclose(fid);
        positionTimes = C{1}(5:5:end);
        positionTimes = cell2mat(positionTimes);
        positionTimes = positionTimes(:,15:27);
    % convert positionTimes to seconds
        [positionTimes_seconds] = convertVideoPositionTime_2Seconds(positionTimes)
    % find spikes that occur in the open field
        spikes_of = spikes.times{cell_idx}(find(spikes.times{cell_idx}> Time.OF.start & spikes.times{cell_idx} < Time.OF.stop));
    % subtract the time of open field start to make the spikes 'align'
    % witht the video - probably need to do this a better way...
        spikes_of = spikes_of - Time.OF.start;
        
    % find spikes in intervals
        positionTimes_startstop(:,1) = positionTimes_seconds(1:end-1,:);
        positionTimes_startstop(:,2) = positionTimes_seconds(2:end,:);
        [status, intervals, index] = InIntervals(spikes_of, positionTimes_startstop);
        figure
        for ispike = 1:length(spikes_of)
            interval_pos = find(positionTimes_startstop(:,1) <= spikes_of(ispike) & positionTimes_startstop(:,2) >= spikes_of(ispike));
            plot(x(interval_pos,1),y(interval_pos,1),'.r');
            hold on
        end 
        title(['Spikes: Cell ' int2str(cell_idx)]);
    end
    
    %%
 %%%%%%%%%%%%%%%%%%% Open field with plot on one side and video on other%%
 %start and stop times need to line up for video and spikes
 % Setup the subplots
ax1 = subplot(2,1,1); % For video
ax2 = subplot(2,1,2); % For raster plot
% Setup VideoReader object
v = VideoReader([basename(1:12) 'VideoOpenField.avi']);
nFrames = v.Duration*v.FrameRate; % Number of frames
% Display the first frame in the top subplot
vidFrame = readFrame(v);
image(vidFrame, 'Parent', ax1);
ax1.Visible = 'off';
% Load the spiking data
%t = 0:0.01:v.Duration; % Cooked up for this example, use your actual data
spikes_of = spikes.times{cell_idx}(find(spikes.times{cell_idx}> Time.OF.start & spikes.times{cell_idx} < Time.OF.stop));
spikes_of = spikes_of - Time.OF.start;
t = spikes_of(1):.001:spikes_of(end); %binning in 1 ms... 

[spikes_logical, edges_spikes] = histcounts(spikes_of,t);
nDataPoints = length(t); % Number of time points
step = round((nDataPoints/nFrames));
bin2video = 1:step:nDataPoints;
spikesPerFrame = zeros(length(bin2video)-1,1)
for ibin = 1:length(bin2video)-1
   spikesPerFrame(ibin,1) = sum(spikes_logical(1,(bin2video(ibin):bin2video(ibin+1))));
end
spikesPerFrame(spikesPerFrame(:,1) >=1,1) = 1;
    %bin spiking data into frame 

i = 2;
% Diplay the plot corresponds to the first frame in the bottom subplot
h = plot(ax2,bin2video(1:index(i)),cell_idx,'-k');
% Fix the axes
ax2.XLim = [t(1) t(end)];
ax2.YLim = [0 5];
% Animate
while hasFrame(v)
    pause(1/v.FrameRate);
    
    vidFrame = readFrame(v);
    image(vidFrame, 'Parent', ax1);
    ax1.Visible = 'off';
    
    i = i + 1;
    set(h,'YData',cell_idx, 'XData', bin2video(1:index(i)))
end
 %%%%%%%%%%%%%%%%%%% Linear Track %%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %run over dlc - get estimated position with timestamps
 %have a raster plot above the video with cells on y axis, and position on
 %x axis - dots appear when the cell fires for 1 second
 

 %%%%%%%%%%%%%%%%%%% Virtual Reality %%%%%%%%%%%%%%%%%%%%%%%%%

 
%%
%1D Linear Track
    % First run DLC (also on Blink Light)
    % kaiser branh of utilities
% Align video to intan
    Vtracking = AlignVidDLC(basepath,varargin);
    Workflow_DLC_to_place_tracking %kaisers script for place cells in LT
% Make place fields again as per 1D VR STIM and NO STIM


% 2D STIM and NO STIM
    % still needs to be made
    [predictedPositionOF] = gtOpenFieldPosition(basePath, 'PositionEstimate.csv');
    TotalOFTime = OF.stop - OF.start;
    OFframespersec = length(predictedPositionOF.xpos)/TotalOFTime;
    openFieldPulseEpochs = pulseEpochs(:,:)> OF.start & pulseEpochs(:,:) < OF.stop;

%Define pyramidal cells
    % vector of spike timestamps, position, and position timestamps
    % everytime a cell fires, grab location,add 1 to the bin for that
    % location. then use imagesc(matrix of spikes per bin)

disp("kachow: you have solved the brain");
