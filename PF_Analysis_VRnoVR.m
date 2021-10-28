%PF_Analysis_VRnoVR
%
% PURPOSE
%           Run analysis over experiments with virtual reality (screens on)
%           and no virtual reality (screen off), with sleep sessions before and
%           after.
%                - LFP
%                - Powerspec and wavespec
%                - Ripples
%                - Firing Rate
%                - Spiking
%                - Place Fields
%                - Videos with spiking
%
% HISTORY
%          Reagan Bullins 03.01.21

%% After data is collected do the following . . .
% Transfer Data
%   Data folder (new computer), csv position and timestamps files & videos
%   (old computer)
% Make a txt doc of recording information
%   Copy and paste chanMap for certain probe in data folder
%   Edit chan map varibales for the mouse
% Rename Variables
%   with basename.dat and xml (make xml by clicking on dat file)
%   click on basename_analogin.dat in folder  (make xml - 8 channels,
%   30000Hz)
%   basename_whatever else
%   keep info rhd same
% Update Data Directory
%   On lab sheets
%   Matlab script: RecordingDirectory_PlaceTuning

%% Run every time
% Define Recording session path
    basePath = 'F:\Data\VR_noVR\m247\m247_210409_102408';
    basename = bz_BasenameFromBasepath(basePath);
    cd(basePath);
    animalPath = 'F:\Data\AnimalSpecs_ExperimentalParadigms';
% Add paths
    addpath(genpath(basePath));
    addpath(genpath('E:\Reagan\Packages\npy-matlab'));
    addpath(genpath('E:\Reagan\Packages\Kilosort2'));
    addpath(genpath('E:\Reagan\Packages\utilities'));
    addpath(genpath('E:\Reagan\Packages\buzcode'));
    addpath(genpath('E:\Reagan\Packages\TStoolbox'));
    addpath(genpath('E:\Reagan\Code'));
    addpath('F:\Data\VR_noVR');
    SetGraphDefaults;

%% Run ONLY Once 
% *DO HAVE TO OPEN* PF_Preprocessing_Pipeline and change path :)
%                  1) change path in kilosort
%                  2) look at rip file in neuroscope to see
%                  if ripples are being detected well
    spikeSorted = 'false'; %true or false, will skip finding spikes if false
    runKilosort = 'false'; %true or false, will run kilosort if true

% Run over kilosort, get spikes, lfp, analogin, digitalin, ripples (if
% files are not already created in folder)
    PF_Preprocessing_Pipeline(basePath, runKilosort, spikeSorted)
% Make mat analysis files
    VRnoVR_Preprocessing_MakeMatFiles
% Ripples
    PF_Preprocessing_Ripples %if get error, make sure your text recording info file has 'Max Ripple Channel' set to a number (chosen by eye)
% Find State of Sleep
    lfp_chans2check = [10 30 60]; %make sure channels are good ones
    [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(basePath,lfp_chans2check, Time.Sleep1.start, Time.Sleep2.stop);      
    save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
        % sleep
              TheStateEditor(basename, SleepEditorInput);
%% Load Mat Files Commonly Used
    cd(basePath);
% Load in start and stop times of each sleep and experimental segment
    load([basename '_TimeSegments.analysis.mat']);
% Load in VR wheel trials
    load([basename '_wheelTrials.analysis.mat']);
%% LFP Analysis - Define and Load Mat files
% Define what lfp channel to use for lfp analysis,
% this is using the channel with the max ripple amplitude
    load([basename '.ripples.events.mat']);
        lfp_channel = ripples.detectorinfo.detectionchannel; %0 based
% Load the analogin points of differnet locations in the unity maze (water
% reward, grating switch, and stim location)
    cd(animalPath);
        load('Maze_Characteristic_Analog_Positions.mat');
% Load analogin (position of unity wheel)
    cd(basePath);
        load([basename '_analogin_VRnoVR.analysis.mat']); %load analogin seperately for VR and no VR segments
% Load start and stop times of VR
    load([basename '_VRTime_BL_Stim.analysis.mat']);
%%  LFP Analysis - Power Spec 
% Power Spectra: Compares each setup to previous sleep, also compares all
% sleep parts to all experimental parts in one figure, compares all sleep
% in one figure, compares all experimental parts in one figure
    % If this has never been ran before, run the whole analysis and plot,
    % if it has been ran before, just plot
    if ~isfile([basename '_IRASA.analysis.mat'])
        [IRASA] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Time, 'doLFPClean', false,'doSPlitLFP',false,'movmean_win',1000);
        save([basename '_IRASA.analysis.mat'], 'IRASA');
    else
        load([basename '_IRASA.analysis.mat']);
        getIRASAPlot_VRnoVR(IRASA, Time);
    end
% Subset of section IRASA - same amount of time 30 min (or specified
% below)
    if ~isfile([basename '_IRASA_subset.analysis.mat'])
        [Time_sub] = getSubsetTime(Time);
        [IRASA_subset] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Time_sub, 'doLFPClean', false,'doSPlitLFP',false,'movmean_win',1000);
         save([basename '_IRASA_subset.analysis.mat'], 'IRASA_subset');
    else
        load([basename '_IRASA_subset.analysis.mat']);
        getIRASAPlot_VRnoVR(IRASA_subset, Time);
    end
% Velocity Power Spectra: Compares power spectra for VR - for data that has velocity over and under a certain threshold
% fix velocity code, runEpochs work?
    [IRASA_VR_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.VR, 'doLFPClean', false, 'doSPlitLFP',false,'movmean_win',1000);
    [IRASA_noVR_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.noVR, 'doLFPClean', false);
% Sleep State spectum comparisoin:
        load([basename '_SleepState.analysis.mat']);
        [IRASA_SleepState] = getPowerSpectrum_SleepState(basePath, lfp_channel, Time, SleepState,'doLFPClean',false, 'doSPlitLFP',false,'movmean_win',1000);
        save([basename '_IRASA_SleepState.analysis.mat'],'IRASA_SleepState');

%% Velocity analysis
    [vel_VR] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
    [vel_noVR] = getVelocity(analogin_noVR,'circDisk',236, 'doFigure', true);%236cm/unity lap
    save('Velocity.analysis.mat','vel_VR','vel_noVR');

    [runEpochs_VR] = getRunEpochs(basePath, vel_VR);
    [runEpochs_noVR] = getRunEpochs(basePath, vel_noVR);
%% LFP Analysis - Power Spec over many recordings
% this script requires you to have each session you want to look at already
% ran over the getPowerSpectrum_PlaceInhibition Script
    % Run the script with all the recordings paths you want to look at
          RecordingDirectory_VRnoVR
    % Plot the std error shaded power spectrum
          getStdErrorPowerSpectra_VRnoVR(recDir)
%% LFP Analysis - WaveSpec - Virtual Reality
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
% Plot some raw ripples in lfp
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
    [numRipples.noVR, rippleLength.noVR]     = getNumAndLength_Ripples(rippleTimestamps.noVR);

% Make box plot of ripple length per segment  
    % Experimental Segments
        ripLengthExp = [rippleLength.VR;rippleLength.noVR];
        groupLength.VR = repmat({'VR'},length(rippleLength.VR),1);
        groupLength.noVR = repmat({'noVR'},length(rippleLength.noVR),1);
        ripLengthExpGroup = [groupLength.VR; groupLength.noVR];
        figure;
            boxplot(ripLengthExp, ripLengthExpGroup);% rippleLength.sleep2])
            hold on;
            ylabel('Ripple Length (s)');
            title('Ripple length of experimental segments');
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
 %% Ripple distributions for singular session
% Make a plot comparing ripple length distribution between different sleep
% segments (chunks of all sleep)
figure;
        Time_sleep_sessions(1,1) = Time.Sleep1.start;
        Time_sleep_sessions(1,2) = Time.Sleep1.stop;
        Time_sleep_sessions(2,1) = Time.Sleep2.start;
        Time_sleep_sessions(2,2) = Time.Sleep2.stop;
        subplot(2,2,1);
          [rippleDistribution.all] = getRippleDurationDistribution_SpecificSleepState(Time_sleep_sessions, Time, ripples);
            title({'Ripple length per sleep session', basename});
% Make a plot comparing ripple length distribution between different sleep
% segments only NREM ripples (only NREM
        subplot(2,2,2);
           [rippleDistribution.NREM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.NREMstate, Time, ripples);
            title({'NREM Ripple length per sleep session', basename}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only REM ripples (only REM)
        subplot(2,2,3);
           [rippleDistribution.REM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.REMstate, Time, ripples);
            title({'REM Ripple length per sleep session', basename}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only Wake ripples (Only awake)
        subplot(2,2,4);
           [rippleDistribution.wake] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.WAKEstate, Time, ripples);
            title({'WAKE Ripple length per sleep session', basename}); 
% Make a figure about ripple length distribution for each experimental
% segment
           [rippleDistribution.exp] = getRippleDurationDistribution_SpecificExperiment(Time, ripples);
           title({'Ripple length per experimental segment', basename});
save([basename '_rippleDistributions.analysis.mat'], 'rippleDistribution');
%% Ripple distribution across sessions

% Load directory with sessions to run over
    RecordingDirectory_VRnoVR;
% Average with std over all sessions (average ripple length distribution)
    segmentTitle = 'exp'; % Option: 'NREM','REM','wake','all', 'exp'
    [rippleExp] = getAvgRippleDistribution(recDir,segmentTitle)
%% Ripples Rate across sessions (section loads all sessions in directory, and calculates the ripple rate during sleep, plots it on a figure)
%   Gives dot plots of ripple rate per experimental session, dot plots of 
%         length of time in sleep state per experimental session, and box 
%         plots of ripple rate and time spend in sleep state over all sessions

    sleepQual = 'NREM'; %Options: NREM, REM, AllSleep
    
    RecordingDirectory_VRnoVR;
   [rippleRateMat,totalTimeMat, rippleRateExpTask] = getRippleRatePlots_VRnoVR(recDir, sleepQual);
% Get p values between all sleep sessions, rank sum and sign rank p values
    [pval_rippleRate_ranksum, pval_rippleRate_signrank] = getBoxPlot_Stats(rippleRateMat);
    [pval_totalTime_ranksum, pval_totalTime_signrank] = getBoxPlot_Stats(totalTimeMat);
    [pval_rippleRateExp_ranksum, pval_rippleRateExp_signrank] = getBoxPlot_Stats(rippleRateExpTask);

%% Firing Rate single sessions
% Gives a boxplot of firing rate per experimental segment, 3 boxes per session (each task is a different
%       color), and sleep can be NREM, REM, or AllSleep (change code below)
    
    sleepQual = 'NREM'; % Options: NREM, REM, AllSleep

   [sleep_FR_mat, exp_FR_mat] = getFR_BoxPlot_SingleSession_VRnoVR(basePath, sleepQual);
    
    [pval_sleepFR_ranksum, pval_sleepFR_signrank] = getBoxPlot_Stats(sleep_FR_mat);
    [pval_expFR_ranksum, pval_expFR_signrank] = getBoxPlot_Stats(exp_FR_mat);
%% Firing Rate across sessions
% Gives a boxplot firing rate per cell per experimental segment (days 
%       spread out on axis), 3 boxes per day (each task is a different
%       color), and sleep can be NREM, REM, or AllSleep (change code below)
    
    sleepQual = 'NREM'; % Options: NREM, REM, AllSleep
   
    RecordingDirectory_VRnoVR;
    getFiringRateBoxPlots_VRnoVR(recDir,sleepQual);

%% Spiking Analysis - Define and load mat files
% Load spike times, cell info from cell explorer,and stim times
    cd(basePath);
       load([basename '.spikes.cellinfo.mat']);
       load([basename '.cell_metrics.cellinfo.mat']);
       load([basename '_pulseEpochs_splitPerSetup.analysis.mat']);
% Define what cell to analyze
    cell_idx = 1;
% Define what part of the experiment to analyze
    exper_paradigm = 'VR'; 
        pulseEpochs_exper = pulseEpch.VR; 
% Define the trials for the experiment to evaluate
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
         xticklabels({'0','1','2','3','4','5','6','7'});
         title(['Cell ' num2str(cell_idx) ':Raw Waveform']);
         box off;
         axis square;
% Spike count Plot around opto stim
     subplot(3,2,3);
        getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, cell_idx);
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
        if strcmp(cell_metrics.putativeCellType{icell}(1:4),'Narr')
            IN_Cell(1,IN_count) = icell;
            IN_count = IN_count+1;
        elseif strcmp(cell_metrics.putativeCellType{icell}(1:4),'Pyra')
            PYR_Cell(1,PYR_count) = icell;
            PYR_count = PYR_count+1;
        end
    end
% Make a figure for each Interneuron: plot of PETH and Raster around stim
    for iUnit = 1:length(IN_Cell)
        fig = figure;
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
        fig = figure;
        % PSTH of one cell around opto stim time (can specify which pulses)
        subplot(2,1,1)
            getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm,PYR_Cell(iUnit)) %'runAllInterneurons', True);
        % Plot Raster of one cell around opto stim time (can specify which pulses)
        subplot(2,1,2)
            getRasterPlots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, PYR_Cell(iUnit));
        % Plot autocorrelation of specified cell inside and outside opto stim
        % epochs
        cd([basePath '\Figures\OptoStim'])
            savefig(cd,['Raster/PETH PYR Cell: ' num2str(PYR_Cell(iUnit))]);
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
% Load cell to look at place fields
    icell_idx = 1;
% Load spike times, analogin of VR wheel, and start and stop times of
% baseline and stim periods
    load([basename '.spikes.cellinfo.mat']);
    load([basename '_analogin_VR.analysis.mat']);
    load([basename '_VRTime_BL_Stim.analysis.mat']);
%% Virtual Reality - Place Fields

% Get the corresponding voltage position of each spike timestamp
      [spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep);
% Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin) 
      [fig, zfig, fr_position] = getPlaceField_VR(cell_idx, spkEpVoltage, tr_ep, len_ep, ts_ep, analogin_VR);
% Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)
      getPopulationPlaceField_VR(basePath, spkEpVoltage, tr_ep_all, len_ep, ts_ep_all, spikes, analogin_VR)
       
 % Colorful Raster of all cells over position (y trials (jittered by cell), x position) dots different color for
 % different cells
    subplot(1,3,1);
        getRasterOverPosition(spkEpVoltage, VR_BL1_Trials);
        title('VR: Pre baseline trials')
    subplot(1,3,2);
        getRasterOverPosition(spkEpVoltage, VR_Stim_Trials);
        title('VR: Stim trials');
    subplot(1,3,3);
        getRasterOverPosition(spkEpVoltage, VR_BL2_Trials);
        title('VR: Post baseline trials');