% Reagans preprocessing pipeline

%%
% Transfer Data
%   Data folder (new computer), csv position and timestamps files & videos
%   (old computer)
% Make a txt doc of recording information
%   List on data overview sheet in notion
%   Copy and paste chanMap for certain probe in data folder
%   Edit chan map varibales for the mouse
% Rename Variables
%   with basename.dat and xml (make xml by clicking on dat file)
%   click on basename_analogin.dat in folder  (make xml - 8 channels,
%   30000Hz)
%   basename_whatever else
%   keep info rhd same
%% Each Time Run This
% Define Recording session path
    basePath = 'F:\mouse1_180412_2'
    basename = bz_BasenameFromBasepath(basePath);
% Add paths
    addpath(genpath(basePath));
    addpath(genpath('E:\Reagan\Packages\npy-matlab'));
    addpath(genpath('E:\Reagan\Packages\Kilosort2'));
    addpath(genpath('E:\Reagan\Packages\utilities'));
    addpath(genpath('E:\Reagan\Packages\buzcode'));
    addpath(genpath('E:\Reagan\Packages\TStoolbox'));
    addpath(genpath('E:\Reagan\Code'));
% Graph Defauls
    SetGraphDefaults;
%% Run Once 
% Run Kilosort2 (updatepath rootZ first with datapath!)
    tic, master_kilosort_reaganp1,toc % so you know how long it takes

% Spikesort

% with buzcode can do below without spike sorting
    cd(basePath)
% getSessionInfo
    sessionInfo = bz_getSessionInfo;
% bz_GetLFP
    bz_LFPfromDat(basePath);
    %lfpChan = 'all';
    %lfp = bz_GetLFP(lfpChan);
% bz_FindRipples
    bz_FindRipples(lfp.data, lfp.timestamps);

% getAnaloginVals FIX THIS (8 channels, 30000Hz)
    analogin = getAnaloginVals(basePath,'wheelChan',5,'pulseChan','none','rewardChan','none','blinkChan',6, 'downsampleFactor',100);
% getDigitalinVals (4= reward, 2 = stim)
    fileinfo = dir(fullfile([basename '_digitalin.dat']));
    num_samples = fileinfo.bytes/2 ; % uint16 = 2 bytes
    fid = fopen([basename '_digitalin.dat'], 'r');
    digital_word = fread(fid, num_samples, 'uint16');
    fclose(fid);
    digital_input_stim = (bitand(digital_word, 2^2) > 0); % ch # goes after the 2^
    digital_input_reward = (bitand(digital_word, 2^4) > 0);
    
    save([basename '_digitalin_rz.mat'], 'digital_input_reward', 'digital_input_stim')
  
% getPulseEpochs % get optoStim
    load([basename '_digitalin_rz.mat']);
    load([basename '_analogin.mat']);
    digitalin.ts = analogin.ts;
    digitalin.pulse = digital_input_stim;
    pulseEpochs = getPulseTimes(digitalin); %epochs in seconds
    
    save([basename '_pulseEpochs_rz.mat'],'pulseEpochs');
%turn pulseEpochs in basename.optostim.manipulation.mat for CellExplorer
% Get Spikes
    spikes = bz_GetSpikes;
    
     %makeRipFile.m
     %makePulseFile.m

%% Split up recording in different parts 
%Convert time - referencing recoringInfo.txt
    [Sleep1_Time] = RealTime_Convert_RecordingTime(basePath, 'SleepTime1');
    [Sleep2_Time] = RealTime_Convert_RecordingTime(basePath, 'SleepTime2');
    [Sleep3_Time] = RealTime_Convert_RecordingTime(basePath, 'SleepTime3');
    [Sleep4_Time] = RealTime_Convert_RecordingTime(basePath, 'SleepTime4');
    [VR_Time] = RealTime_Convert_RecordingTime(basePath, 'VRTime');
    [OF_Time] = RealTime_Convert_RecordingTime(basePath, 'OFTime');
    [LT_Time] = RealTime_Convert_RecordingTime(basePath, 'LTTime');

% Trials from wheel chan getWheelTrials (only want wheel trials during VR
% time)
    cd(basePath);
    load([basename '_analogin.mat']);
    analogin_VR.pos = analogin.pos(VR_Time.start*30000:VR_Time.stop*30000);
    analogin_VR.blink = analogin.blink(VR_Time.start*30000:VR_Time.stop*30000);
    analogin_VR.ts = analogin.ts(VR_Time.start*30000:VR_Time.stop*30000);
    analogin_VR.sr = analogin.sr;
    [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials_RB(analogin_VR);
    
    %check wheel trials with this
%         plot(analogin.pos)
%         hold on
%         for i = 1:length(tr_ep)
%             xline(tr_ep(i,1)*30000,'g')
%             xline(tr_ep(i,2)*30000,'r')
%         end
    [pulseIdx, noPulseIdx, pulseEpochs] = getPulseTrialIdx(analogin_VR, tr_ep);
% Split up baseline, stim, and post baseline times
    load([basename '_pulseEpochs_rz.mat']);
    stimEpochs_VR = pulseEpochs(:,:)> VR_Time.start & pulseEpochs(:,:) < VR_Time.stop;
        pulseEpch.VR(:,1) = pulseEpochs(stimEpochs_VR(:,1));
        pulseEpch.VR(:,2) = pulseEpochs(stimEpochs_VR(:,2));
    stimEpochs_OF = pulseEpochs(:,:)> OF_Time.start & pulseEpochs(:,:) < OF_Time.stop;   
        pulseEpch.OF(:,1) = pulseEpochs(stimEpochs_OF(:,1));
        pulseEpch.OF(:,2) = pulseEpochs(stimEpochs_OF(:,2));
    stimEpochs_LT = pulseEpochs(:,:)> LT_Time.start & pulseEpochs(:,:) < LT_Time.stop;
        pulseEpch.LT(:,1) = pulseEpochs(stimEpochs_LT(:,1));
        pulseEpch.LT(:,2) = pulseEpochs(stimEpochs_LT(:,2));
% Velocity from wheel chan getVelocity

                    
 %%  LFP Analysis  - Define experimental paradigm
exper_paradigm = 'VR'; %'LT' 'OF'
Time_exper = VR_Time; %'.OF' '.LT'
cell_idx = 1;
lfp_channel = 4;
% Poweranalysis run/no-run
    % getPowerSpectrum in utilities (or something very similar)
    %lfp_exp = bz_GetLFP('all','intervals', [Time_exper.start Time_exper.stop]);
    lfp_exp = bz_GetLFP(lfp_channel, 'intervals',[Time_exper.start Time_exper.stop]);
    [runEpochs] = getRunEpochs(basePath, vel_ep);%check this
    %make lfp run and no run interval for power spectrum (something wrong
    %here)
          %[pow] = getPowerSpectrum(basePath, lfp_exp); 
    %for each exper setup
    
    % power analysis - reagan from sujiths class
        sampling_freq=lfp_exp.samplingRate; % Set Sampling frequency
        dt=1/sampling_freq; % Sampling interval 
        rec_time=length(lfp.data(:,1))./sampling_freq; % total recording time 
        freq_dat_1= fft(lfp.data(:,1)); %Calculate the Fourier Transform 
        Pow_spec=(2*(dt^2)/rec_time)*abs(freq_dat_1); 
        Pow_spec2=Pow_spec(1:(length(lfp.data(:,1))/(2))+1);
        df=1/max(rec_time);
        fnq= sampling_freq/2; 
        freq_axis=(0:df:fnq); 
        plot(freq_axis,Pow_spec2) % Plot power spectrum
        xlim([0 150]) 
        xlabel('Frequency Hz')
        ylabel ('Power') 
    
% lfp analyses
    % Detect ripples bz_FindRipples
    % Validate in Neuroscope if ripples are correctly detected


%% OptoStim Analysis - Define experimental paradigm
exper_paradigm = 'VR'; %'LT' 'OF'
pulseEpochs_exper = pulseEpch.VR; %'.OF' '.LT'
cell_idx = 1;
timwin = [-0.4 0.4];
binSize = 0.01;

load([basename '.spikes.cellinfo.mat']);
% Perstimulus time histogram all stims together(rate) 
     [peth] = getPETH_epochs(basePath,'epochs', pulseEpochs,'timwin',timewin, ...
        'binSize', binSize, 'saveAs', ['.pethPulse' exper_paradigm '.analysis.mat']);
      figure;
      bar(1:length(peth.timeEdges)-1, peth.rate(cell_idx,:));
      title(['PSTH centered to all stims: Cell ' num2str(cell_idx)]);
      ylabel('Count');
      xlabel('Time to Pulse (ms)');
      xticks([0 20 40 60 80]);
      xticklabels({'-400','-200','0','200','400'});
% Perstimulus time histogram ONLY specified stim experiment
     [peth] = getPETH_epochs(basePath,'epochs', pulseEpochs_exper,'timwin',timewin, ...
        'binSize', binSize, 'saveAs', ['.pethPulse' exper_paradigm '.analysis.mat']);
      figure;
      bar(1:length(peth.timeEdges)-1, peth.rate(cell_idx,:));
      title(['PSTH centered to ' exper_paradigm ' stims: Cell' num2str(cell_idx)]);
      ylabel('Count');
      xlabel('Time to Pulse (ms)');
      xticks([0 20 40 60 80]);
      xticklabels({'-400','-200','0','200','400'});
% Raster Plot for all stims of ONE cell
      figure;
%       for itrial = 1:length(pulseEpochs)
%           [status, interval, index] = InIntervals(spikes.times{cell_idx}, pulseEpochs(itrial,:));
%           spikes_during_trial = spikes.times{cell_idx}(status);
%           plot(spikes_during_trial, itrial*ones(length(spikes_during_trial)),'.r');
%           hold on
%       end
        timeEdges   = timwin(1):binSize:timwin(2);
        timeBefore  = abs(timwin(1));
        timeAfter   = timwin(2);
        trlCenteredEpochStart   = pulseEpochs(:,1)-timeBefore;
        trlCenteredEpochStop    = pulseEpochs(:,1)+timeAfter;
        trlCenteredEpoch = [trlCenteredEpochStart trlCenteredEpochStop];
        % Align the spikes to be centered around epoch start
        spike_toEpochStart = realignSpikes(spikes, trlCenteredEpoch);
        figure;
        for iEpoch = 1:length(pulseEpochs)
         spikeTrl{iEpoch} = spike_toEpochStart{cell_idx}{iEpoch} - pulseEpochs(iEpoch,1);
         plot(spikeTrl{iEpoch}, iEpoch*ones(length(spikeTrl{iEpoch})),'.r');
         hold on;
        end 
        
        title(['Raster centered to all stims: Cell ' num2str(cell_idx)])
        ylabel('Trial');
        xlabel('Time to Pulse(ms)');
        xticklabels({'-400','-200','0','200','400'});
% Raster Plot for ONLY specified stim experiment of ONE cell
        figure;
        timeEdges   = timwin(1):binSize:timwin(2);
        timeBefore  = abs(timwin(1));
        timeAfter   = timwin(2);
        trlCenteredEpochStart   =  pulseEpochs_exper(:,1)-timeBefore;
        trlCenteredEpochStop    =  pulseEpochs_exper(:,1)+timeAfter;
        trlCenteredEpoch = [trlCenteredEpochStart trlCenteredEpochStop];
        % Align the spikes to be centered around epoch start
        spike_toEpochStart = realignSpikes(spikes, trlCenteredEpoch);
        figure;
        for iEpoch = 1:length( pulseEpochs_exper)
         spikeTrl{iEpoch} = spike_toEpochStart{cell_idx}{iEpoch} -  pulseEpochs_exper(iEpoch,1);
         plot(spikeTrl{iEpoch}, iEpoch*ones(length(spikeTrl{iEpoch})),'.r');
         hold on;
        end 
        title(['Raster centered to ' exper_paradigm ' stims: Cell ' num2str(cell_idx)]);
        ylabel('Trial');
        xlabel('Time to Pulse (ms)'); 
        xticklabels({'-400','-200','0','200','400'});
% getCCGinout
    [ccginout] = getCCGinout(basePath, spikes, pulseEpochs_exper); %I changed this function to have spikes as an input
    plot(ccginout.ccgIN(:,cell_idx, cell_idx));
    plot(ccginout.ccgOUT(:,cell_idx, cell_idx));
    
%run CellExplorer
    

%% Virtual Reality
    cell_idx = 1;
%1D VR - VR STIM and NO STIM
    % should work with some messy place cell code from Lianne ->
    % optimization is necessary & maybe combine or use buzcode scripts - check
    % it out bz_findPlaceFields1D
    % getWheelTrials;plotRastersTrials
        %Process: for each timestamp -- find corresponding wheel voltage
                 % split into wheel trials 
                 % bin voltage 
                 % average all trials
                 % place in a matrix (each row = 1 cell)
                 % sort the rows by increasing index value (pretty picture)
    % load analogin 
        load([basename '_analogin.mat']);
    % get wheel trials
        [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin_VR);
    % define time and position of wheel using analogin  
        ts  = analogin.ts;
        pos = analogin.pos;
    %Generate spk_ep (find the position of each spike in each trial lap)
        for iUnit = 1:length(spikes.UID)
            for iTr = 1:length(tr_ep)
               [status,interval] = InIntervals(spikes.times{iUnit},tr_ep);
               spk_ep{iUnit}.trial{iTr} = spikes.times{iUnit}(interval==iTr); 

              % find associated voltage to each spike in the trial
              spkEpVoltIdx = find(ismember(ts,spk_ep{iUnit}.trial{iTr}));
              spkEpVoltage{iUnit}.trial{iTr} = pos(spkEpVoltIdx);
            end

        end
         bin_voltage = max(analogin.pos)/100; %check length of VR track
    % for one cell over many trials
         spkCt_Position = zeros(length(tr_ep), length(0:bin_voltage:max(analogin.pos))-1);
         for itrial = 1:length(tr_ep)
          [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),0:bin_voltage:max(analogin.pos)); % 100 for each cm?
          %make the first row of the matrix equal to the spikes per spatial
          %bin just found
          spkCt_Position(itrial,:) = count; 
         end 
         figure;
         imagesc(spkCt_Position);
         
    % for multiple cells averaged over multiple trials
         avg_spk_ct_position = zeros(size(spikes.times,2),length(0:bin_voltage:max(analogin.pos))-1);
        for icell = 1:size(spikes.times,2) 
            spkCt_Position = zeros(length(tr_ep), length(0:bin_voltage:max(analogin.pos))-1);
         for itrial = 1:length(tr_ep)
          [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),0:bin_voltage:max(analogin.pos)); % 100 for each cm?
          %make the first row of the matrix equal to the spikes per spatial
          %bin just found
          spkCt_Position(itrial,:) = count; 
         end 
             avg_spk_ct_position(icell,:) = mean(spkCt_Position);
             %normalize for time spent in area
        end
         sorted_cells_by_ct = sortrows(avg_spk_ct_position);
         figure;
         imagesc(sorted_cells_by_ct);
         title('All Cells')
         ylabel('Cell Number')
         xlabel('Position')
         
        % split up analogin by wheel trials REMOVE this??
        bin_voltage = max(analogin.pos)/100; %check length of VR track
        [status, interval] = cellfun(@(a) InIntervals(a, wheel_trial_bin), spikes.times);
        [count, edges] = histcounts(spikes.times{status},0:bin_voltage:length(analogin.pos)); % 100 for each cm?
    % average over trials (down columns for each cell)
        
        
%% Videos with spiking on top
    
    cell_idx = 1; %define what cell to map
    %%%%%%%%%%%%%%%%% OPEN FIELD %%%%%%%%%%%%%%%%%%%%%%%%
    cd([basePath '\Videos_CSVs']);
    v = VideoReader([basename(1:12) 'VideoOpenField.avi']);
    positionEstimate_file = csvread([basename(1:12) 'PositionEstimate.csv']);
    x = positionEstimate_file(:,1);
    y = positionEstimate_file(:,2);
    fid = fopen([basename(1:12) 'PositionTimestamps.csv']);
    C = textscan(fid,'%s','HeaderLines',8,'Delimiter',',','EndOfLine','\r\n','ReturnOnError',false);
    fclose(fid);
    positionTimes = C{1}(5:5:end);
    positionTimes = cell2mat(positionTimes);
    positionTimes = positionTimes(:,15:27);
    % for 21 session:  frames = 35831, estimates = 35372
  
    % Frames to which marker must be inserted
    markFrames = spikes.times{cell_idx};
    %frameidx = 0;
    videoPlayer = vision.VideoPlayer;
    for frameidx = 1:VideoReader.NumFrames %wile hasFrame(v)
        % Read next video frame
        frame = readFrame(v);
        frameidx = frameidx + 1;
        % Check if index of frame is to be marked or not
        if any(ismember(markFrames, frameidx))
            markedFrame = insertMarker(frame, [x(frameidx) y(frameidx)]);
            videoPlayer(markedFrame);
        else
            videoPlayer(frame);
        end
    end
 %%%%%%%%%%%%%%%%%%% Linear Track %%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

 %%%%%%%%%%%%%%%%%%% Virtual Reality %%%%%%%%%%%%%%%%%%%%%%%%%
 % trials baseline (y trials, x position) dots different color for
 % different cells

%%
%1D Linear Track
    % First run DLC (also on Blink Light)

% Align video to intan
    Vtracking = AlignVidDLC(basepath,varargin);

% Make place fields again as per 1D VR STIM and NO STIM


% 2D STIM and NO STIM
    % still needs to be made
    [livePositionOF] = gtOpenFieldPosition(basePath, 'PositionEstimate.csv');
    TotalOFTime = OF_Time.stop - OF_Time.start;
    OFframespersec = length(livePositionOF.xpos)/TotalOFTime;
    openFieldPulseEpochs = pulseEpochs(:,:)> OF_Time.start & pulseEpochs(:,:) < OF_Time.stop;

%Define pyramidal cells
    % vector of spike timestamps, position, and position timestamps
    % everytime a cell fires, grab location,add 1 to the bin for that
    % location. then use imagesc(matrix of spikes per bin)


disp("kachow: you have solved the brain");


