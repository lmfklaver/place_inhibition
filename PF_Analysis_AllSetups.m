%PF_Analysis_AllSetups
%
% PURPOSE
%          Run analysis over full day experiments including linear track,
%          open field, and virtual reality rigs, plus 4 sleep sessions.
%              - LFP
%              - Wavespec and Powerspec
%              - Ripple
%              - Firing Rate
%              - Spiking 
%              - Place fields
%              - Videos with spiking activity
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
    basePath = 'F:\Data\PlaceTuning_VR_OF_LT\m247\m247_210421_083423';
    %basePath = 'F:\Data\PlaceTuning_VR_OF_LT\m246\m246_210607_081650';
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
    addpath('F:\Data\PlaceTuning_VR_OF_LT'); %has directory of all sessions
    SetGraphDefaults;
%% Run ONLY Once 
% *DO HAVE TO OPEN* PF_Preprocessing_Pipeline and change path :)
%                  1) change path in kilosort
%                  2) look at rip file in neuroscope to see
%                  if ripples are being detected well

    spikeSorted = 'false'; %true or false, is the data spike sorted?
    runKilosort = 'false'; %true or false, do you want to run kilosort?
    
% Run over kilosort, get spikes, lfp, analogin, digitalin, ripples (if
% files are not already created)
    PF_Preprocessing_Pipeline(basePath, runKilosort, spikeSorted);
% Make mat analysis files
    PF_Preprocessing_MakeMatFiles
% Ripples
    PF_Preprocessing_Ripples %if get error, make sure your text recording info file has 'Max Ripple Channel' set to a number (chosen by eye)
% Validate Sleep 
    lfp_chans2check = [10 30 60]; %make sure channels are good ones
    [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(basePath,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
    save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
        % sleep
              TheStateEditor(basename, SleepEditorInput)
%% Load Mat Files Commonly Used
    cd(basePath);
% Load in start and stop times of each sleep and experimental segment
    load([basename '_TimeSegments.analysis.mat']);
% Load VR wheel trials
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
        load([basename '_analogin_VR.analysis.mat']);
% Load start and stop times of VR
    load([basename '_VRTime_BL_Stim.analysis.mat']);
%%  LFP Analysis - Power Spectra (checks if mat file exist before doing all analysis)
% Power Spectra without fractals: Compares each setup to previous sleep, also compares all
% sleep parts to all experimental parts in one figure, compares all sleep
% in one figure, compares all experimental parts in one figure

    % If this has never been ran before, run the whole analysis and plot,
    % if it has been ran before
    if ~isfile([basename '_IRASA.analysis.mat'])
        [IRASA] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time, 'doLFPClean', false, 'doSPlitLFP',false,'movmean_win',1000);
        save([basename '_IRASA.analysis.mat'], 'IRASA');
    else
        load([basename '_IRASA.analysis.mat']);
        getIRASAPlot_PlaceInhibition(IRASA, Time);
    end
% Subset of section IRASA - same amount of time 30 min (or specified
% below)
    if ~isfile([basename '_IRASA_sub.analysis.mat'])
        [Time_sub] = getSubsetTime(Time);
        [IRASA_subset] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time_sub, 'doLFPClean', false, 'doSPlitLFP',false,'movmean_win',1000);
        save([basename '_IRASA_sub.analysis.mat'], 'IRASA_subset');
    else
        load([basename '_IRASA_sub.analysis.mat']);
        getIRASAPlot_PlaceInhibition(IRASA_subset, Time);
    end
% Velocity Power Spectra: Compares power spectra for VR - for data that has velocity over and under a certain threshold
       [IRASA_velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Time.VR, 'doLFPClean', false,'doSplitLFP',false,'movmean_win',1000);
% Sleep Spectrum NREM REM
        load([basename '_SleepState.analysis.mat']);
        [IRASA_SleepState] = getPowerSpectrum_SleepState(basePath, lfp_channel, Time, SleepState,'doLFPClean',false,'doSplitLFP',false,'movmean_win',1000);
        save([basename '_IRASA_SleepState.analysis.mat'],'IRASA_SleepState');
%% LFP Analysis - Power Spec over many recordings
% this script requires you to have each session you want to look at already
% ran over the getPowerSpectrum_PlaceInhibition Script
    % Run the script with all the recordings paths you want to look at
          RecordingDirectory_PlaceTuning;
    % Plot the std error shaded power spectrum
          [VR_osci_rows, LT_osci_rows, OF_osci_rows] = getStdErrorPowerSpectra_PlaceInhibition(recDir);
    % Plot all sessions as lines, not with shaded std error
          [VR_osci_rows, LT_osci_rows, OF_osci_rows] = getStdErrorPowerSpectra_PlaceInhibition(recDir, 'withStdError',false);
%% LFP Analysis - PowerSpectra and Wavespec for specified periods
% Get wavespecs around different events - currently stim location, reward
% location, and grating change

% NOTE: Stim location changed from 1.5 to 1.1 on 5/25/21. 
% Experiments BEFORE this date, should use the variable
% 'stim_pos_old' - go into the script and change the input variable to
% such.
    getWavespecsAroundEvents_VR
%% Ripples Analysis - Load and Define
    cd(basePath);
    load([basename '.ripples.events.mat']);
    load([basename '_SleepState.analysis.mat']);
%% Ripple Analysis - singular session
% Plot some raw ripples in lfp (bandpass filter 100 250)
    subplot(3,2,1)
        plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(1,1)*1250):round(ripples.timestamps(1,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
    subplot(3,2,2)
       plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(100,1)*1250):round(ripples.timestamps(100,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
    subplot(3,2,3)
        plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(200,1)*1250):round(ripples.timestamps(200,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
    subplot(3,2,4)
       plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(300,1)*1250):round(ripples.timestamps(300,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
    subplot(3,2,5)
       plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(400,1)*1250):round(ripples.timestamps(400,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
        hold on;
        xlabel('Ripple Time (ms)')
        ylabel('mV')
    subplot(3,2,6)
        plot(bandpass(double(lfp_rip.data(round(ripples.timestamps(500,1)*1250):round(ripples.timestamps(500,2)*1250))*.195),[100,250],1250));
        xlim([0 100]);
    sgtitle('Raw Traces of Ripples (BP filtered)') 
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
            hold on;
            ylabel('Ripple Length (s)');
            title('Ripple length of experimental segments');
    % Sleep Segments
        ripLengthSleep = [rippleLength.sleep1;rippleLength.sleep2; rippleLength.sleep3;rippleLength.sleep4];
        groupLength.sleep1 = repmat({'Sleep 1'},length(rippleLength.sleep1),1);
        groupLength.sleep2 = repmat({'Sleep 2'},length(rippleLength.sleep2),1);
        groupLength.sleep3 = repmat({'Sleep 3'},length(rippleLength.sleep3),1);
        groupLength.sleep4 = repmat({'Sleep 4'},length(rippleLength.sleep4),1);
        ripLengthSleepGroup = [groupLength.sleep1; groupLength.sleep2; groupLength.sleep3; groupLength.sleep4];
        figure;
            boxplot(ripLengthSleep, ripLengthSleepGroup);% rippleLength.sleep2])
            hold on;
            ylabel('Ripple Length (s)');
            title('Ripple length of sleep segments');
        
% Make a Plot comparing number of ripples
        warm_colors = hot(20); %3,7,10,12
        cool_colors = cool(20);%3, 7, 11, 18
        subplot(1,2,1)
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
            hold on;
            plot(1, numRipples.OF,'o','Color',cool_colors(7,:));
            plot(1, numRipples.LT,'o','Color',cool_colors(11,:));
        
            xlim([0 2])
            legend({'VR','OF','LT'});
            ylabel('Number of Ripples')
%% Ripple distributions for singular session
% Make a plot comparing ripple length distribution between different sleep
% segments (chunks of all sleep)
figure;
        Time_sleep_sessions(1,1) = Time.Sleep1.start;
        Time_sleep_sessions(1,2) = Time.Sleep1.stop;
        Time_sleep_sessions(2,1) = Time.Sleep2.start;
        Time_sleep_sessions(2,2) = Time.Sleep2.stop;
        Time_sleep_sessions(3,1) = Time.Sleep3.start;
        Time_sleep_sessions(3,2) = Time.Sleep3.stop;
        Time_sleep_sessions(4,1) = Time.Sleep4.start;
        Time_sleep_sessions(4,2) = Time.Sleep4.stop;
        subplot(2,2,1);
          [rippleDistribution.all] = getRippleDurationDistribution_SpecificSleepState(Time_sleep_sessions, Time, ripples);
            title({'Ripple length per sleep session',basename});
% Make a plot comparing ripple length distribution between different sleep
% segments only NREM ripples (only NREM
        subplot(2,2,2);
          [rippleDistribution.NREM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.NREMstate, Time, ripples);
            title({'NREM Ripple length per sleep session',basename}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only REM ripples (only REM)
        subplot(2,2,3);
          [rippleDistribution.REM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.REMstate, Time, ripples);
            title({'REM Ripple length per sleep session',basename}); 
 % Make a plot comparing ripple length distribution between different sleep
% segments only Wake ripples (Only awake)
        subplot(2,2,4);
          [rippleDistribution.wake] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.WAKEstate, Time, ripples);
            title({'WAKE Ripple length per sleep session',basename}); 
% Make a figure about ripple length distribution for each experimental
% segment
       [rippleDistribution.exp] = getRippleDurationDistribution_SpecificExperiment(Time, ripples);
       title({'Ripple length per experimental segment',basename});
save([basename '_rippleDistributions.analysis.mat'], 'rippleDistribution');
%% Ripple distribution across sessions

% Load directory with sessions to run over
    RecordingDirectory_PlaceTuning;
% Average with std over all sessions (average ripple length distribution)
    segmentTitle = 'exp'; % Option: 'NREM','REM','wake','all', 'exp'
    [rippleExp] = getAvgRippleDistribution(recDir,segmentTitle);
    xticks([0 10 20 30 40 50]);
    bin_length = [0:.006:.3];
    xticklabels({'0',num2str(bin_length(10)),num2str(bin_length(20)),num2str(bin_length(30)),...
                     num2str(bin_length(40)),num2str(bin_length(50))});
    legend('VR','','OF','','LT',''); %always this order
%% Ripples across sessions (section loads all sessions in directory, and calculates the ripple rate during NREM sleep, plots it on a figure)
% Gives dot plots of ripple rate per experimental session, dot plots of
%       length of time in sleep state per experimental session, box plots
%       of ripple rate and time spent in sleep state over all sessions, and
%       box plots of ripple rate per sleep session and ripple rate per
%       sleep session following a specific task

    sleepQual = 'NREM'; % Options: NREM, REM, AllSleep

    RecordingDirectory_PlaceTuning;
    [rippleRateMat,totalTimeMat, rippleRateExpTask] = getRippleRatePlots_PlaceInhibition(recDir, sleepQual);
% Get p values between all sleep sessions, rank sum and sign rank p values
    [pval_rippleRate_ranksum, pval_rippleRate_signrank] = getBoxPlot_Stats(rippleRateMat);
    [pval_totalTime_ranksum, pval_totalTime_signrank] = getBoxPlot_Stats(totalTimeMat);
    [pval_rippleRateExp_ranksum, pval_rippleRateExp_signrank] = getBoxPlot_Stats(rippleRateExpTask);
%% Firing Rate single session
% Gives a boxplot of firing rate per per experimental segment, there are 3 boxes per day (each task is a 
%       different color), and sleep can be NREM, REM, or AllSleep (change code below)
     %MUST be spikesorted
    sleepQual = 'NREM'; % Options: NREM, REM, AllSleep
    
    [sleep_FR_mat, exp_FR_mat] = getFR_BoxPlot_SingleSessoin_PlaceInhibition(basePath, sleepQual);
    [pval_sleepFR_ranksum, pval_sleepFR_signrank] = getBoxPlot_Stats(sleep_FR_mat);
    [pval_expFR_ranksum, pval_expFR_signrank] = getBoxPlot_Stats(exp_FR_mat);
%% Firing Rate across sessions
% Gives a boxplot of firing rate per cell per experimental segment (days 
%       spread out on axis), there are 3 boxes per day (each task is a 
%       different color), and sleep can be NREM, REM, or AllSleep (change code below)
    
    sleepQual = 'NREM'; % Options: NREM, REM, AllSleep
    
    RecordingDirectory_PlaceTuning;
    getFiringRateBoxPlots_PlaceInhibition(recDir,sleepQual);
    %% Spiking Analysis - Define and load mat files
% Load spike times, cell info from cell explorer, and stim times    
    cd(basePath);
        load([basename '.spikes.cellinfo.mat']);
        load([basename '.cell_metrics.cellinfo.mat']);
        load([basename '_pulseEpochs_splitPerSetup.analysis.mat']);
% Define what cell to analyze
    cell_idx = 1;
% Define what part of the experiment to evaluate
    exper_paradigm = 'VR'; %'LT' 'OF'
        pulseEpochs_exper = eval(['pulseEpch.' num2str(exper_paradigm)]);
% Define the trials for the expeirment to evaluate
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
        if strcmp(cell_metrics.putativeCellType{icell}(1:4), 'Narr')
            IN_Cell(1,IN_count) = icell;
            IN_count = IN_count+1;
        elseif strcmp(cell_metrics.putativeCellType{icell}(1:4), 'Pyra')
            PYR_Cell(1,PYR_count) = icell;
            PYR_count = PYR_count+1;
        end
    end
% Make a figure for each Interneuron: plot of PETH and Raster around stim
    for iUnit = 1:length(IN_Cell)
        fig = figure;
        % PSTH of one cell around opto stim time (can specify which pulses)
        subplot(2,1,1);
            getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm,IN_Cell(iUnit)) %'runAllInterneurons', True);
        % Plot Raster of one cell around opto stim time (can specify which pulses)
        subplot(2,1,2);
            getRasterPlots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, IN_Cell(iUnit));
        % Plot autocorrelation of specified cell inside and outside opto stim
        % epochs
        cd([basePath '\Figures\OptoStim']);
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
% Load cell to look at place fields 
    icell = 1;
% Load spike times, analogin of VR wheel, and start and stop times of
% baseline and stim periods
    load('m247_210421_083423.spikes.cellinfo.mat');
    load('m247_210421_083423_analogin_VR.analysis.mat');
    load([basename '_VRTime_BL_Stim.analysis.mat']);
%% Virtual Reality Place Fields
%position at begging of maze = 2.5
% water reward (voltage drop) = .8
   
% Get the corresponding voltage position of each spike timestamp
      [spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep);
      save([basename '_spkEpVoltage.analysis.mat'], 'spkEpVoltage');
% Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin)
      [fig, zfig, fr_position] = getPlaceField_VR(icell, spkEpVoltage, tr_ep, len_ep, ts_ep);
      savefig(['Cell' num2str(icell) '_PlaceField.fig'])
      delete(fig);

% Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)
    getPopulationPlaceField_VR(basePath, tr_ep, len_ep, ts_ep, spikes, analogin_VR)
         
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
 
%% Open Field and Linear Track - define and load
% Define dimensions of setups (in centimeters)
        LTDimensions.xlength = 160;
        LTDimensions.ylength = 8.5;
        OFDimensions.xlength = 60.96;
        OFDimensions.ylength = 60.96;
% Synchronize neural data with video
    % Open Field - check what the output is with kaiser and (right column?)
        % requires DLC position out
        % Align OF video to intan (go to dir with video, find csv file,
        % plug into function)
            videoPathOF = ([basePath '\Videos_CSVs\' basename '_VideoOpenField\']);
            OF_CSV = dir(fullfile(videoPathOF, '*.csv'));
            OFPositionDLC_CSV = convertCharsToStrings(OF_CSV.name);
            VtrackingOF = AlignVidDLC(basePath,videoPathOF,OFPositionDLC_CSV,'syncChan',6);
    % Linear Track
        % Align LT video to intan 
            videoPathLT = ([basePath '\Videos_CSVs\' basename '_VideoLinearTrack\']);
            LT_CSV = dir(fullfile(videoPathLT, '*.csv'));
            LTPositionDLC_CSV = convertCharsToStrings(LT_CSV.name);
            VtrackingLT = AlignVidDLC(basePath,videoPathLT,LTPositionDLC_CSV,'syncChan',6);
% load spikes
    cd(basepath);
    load([basename '.spikes.cellinfo.mat']);
%% Plot position of spikes of each cell (open field and linear track)
    for icell = 1:length(spikes.times)
        figure;
        %Plot one cell spikes in open field 
        subplot(1,2,1);
            getSpikePositionPlot(icell, spikes,VtrackingOF,Time.OF); % OFDimensions);
            title(['Open Field Spikes, Cell: ' icell]);
        %Plot one cell spikes in linear track
        subplot(1,2,2);
            getSpikePositionPlot(icell, spikes,VtrackingLT,Time.LT, LTDimensions);
            title(['Linear Track Spikes, Cell: ' icell]);
    end
%% Linear Track Place Fields    
        
  % Workflow_DLC_to_place_tracking %kaisers script for place cells in LT
    getPlaceField_FreelyMoving(spikes, cell_idx, VtrackingLT, LT.Time)
%% Open Field place field
    getPlaceField_FreelyMoving(spikes, cell_idx, VtrackingOF, OF.Time)
%% Open Field Videos with spiking on top
    %Note: the video may blink, if a position is not detected by bonsai
    %(the model failed to pick up location for that point)

    % Two ways to assign position to different spikes
            % 1) bin the spikes in 1 ms bins
            %    calculate how many bins per frame
            %    count how many spikes fall into each bin
            %    if more than one spike, make it equal to one
            % 2) get the position times outputted from bonsai (should
            %     match up with the position estimate locations)
            %    find the corresponding bin for each spike (spike < bin
            %    stop and spike > bin start, this is the position of the
            %    animal then)
  
    OF_SingleCell_Video
   
    %% working progress - code blurb (want to make a video alined to raster)
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
spikes_of = spikes.times{cell_idx}(spikes.times{cell_idx}> Time.OF.start & spikes.times{cell_idx} < Time.OF.stop);
t = spikes_of(1):.001:spikes_of(end); %binning in 1 ms... 

[spikes_logical, edges_spikes] = histcounts(spikes_of,t);
nDataPoints = length(t); % Number of time points
step = round((nDataPoints/nFrames));
bin2video = 1:step:nDataPoints;
spikesPerFrame = zeros(length(bin2video)-1,1);
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
disp("kachow: you have solved the brain");
