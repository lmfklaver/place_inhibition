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
% Figure out baseline vs stim laps in Virtual Reality (CHECK WITH LIANNE)
%     VR_Stim_Trial_logical(:,1) = zeros(length(tr_ep),1);
%      for iwheeltrial = 1:length(tr_ep)
%             if stimEpochs_VR(1,1) > tr_ep(iwheeltrial,1) && stimEpochs_VR(1,2) < tr_ep(iwheeltrial,2)
%                 VR_Stim_Trial_logical(iwheeltrial,1) = 1;
%             else
%                 VR_Stim_Trial_logical(iwheeltrial,1) = 0;
%             end
%      end
     VR_stim_epch_idx = find(stimEpochs_VR(1,1) > tr_ep(:,1) & stimEpochs_VR(1,2) < tr_ep(:,2));
     find_stim2bL = diff(VR_stim_epch_idx);
     %start and stop trials of manipulation
     VR_BL1_Trials(:,1) = tr_ep(1:find(find_stim2bL == 1),1);
     VR_BL1_Trials(:,2) = tr_ep(1:find(find_stim2bL == 1),2);
     VR_Stim_Trials(:,1) = tr_ep(find(find_stim2bL == 1)+1:find(find_stim2bL == -1),1);
     VR_Stim_Trials(:,2) = tr_ep(find(find_stim2bL == 1)+1:find(find_stim2bL == -1),2);
     VR_BL2_Trials(:,1) = tr_ep(find(find_stim2bL == -1)+1:end,1);
     VR_BL2_Trials(:,2) = tr_ep(find(find_stim2bL == -1)+1:end,2);
     % start and stop times of manipulation
     VR_Stim_Time.start = tr_ep(find(find_stim2bL == 1))+1);
     VR_Stim_Time.stop = tr_ep(find(find_stim2bL == -1));
     VR_BL1_Time.start = VR_Time.start;
     VR_BL1_Time.stop = VR_Stim_Time.start;
     VR_BL2_Time.start = VR_Stim_Time.stop; 
     VR_BL2_Time.stop = VR_Time.stop;
                    
%%  LFP Analysis - Define experimental paradigm
% Power Spectra  
     lfp_channel = 21;
     getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Sleep1_Time, Sleep2_Time, Sleep3_Time, Sleep4_Time, VR_Time, OF_Time, LT_Time)

    %[runEpochs] = getRunEpochs(basePath, vel_ep);
% Ripples
    % Detect ripples bz_FindRipples
    % Validate in Neuroscope if ripples are correctly detected

%% Single Cell Characteristics
 cell_idx = 1;
 plot(spikes.rawWaveform{cell_idx});
 
 % Get firing rate for different experimental setups
     fr_VR_baseline = InIntervals(spikes, [VR_Time.start ])
 % boxplot (x axis is cell type or exper chunk (y is firing rate)
     
%% OptoStim Analysis - Define experimental paradigm
exper_paradigm = 'VR'; %'LT' 'OF'
pulseEpochs_exper = pulseEpch.VR; %'.OF' '.LT' pulseEpochs
cell_idx = 1;

% PSTH of one cell around opto stim time (can specify which pulses)
    getPSTHplots_PlaceInhibition(basePath, pulseEpochs_exper, exper_paradigm, cell_idx);
% Plot Raster of one cell around opto stim time (can specify which pulses)
    getRasterPlots_PlaceInhibition(basePath, pulseEpochs, exper_paradigm, cell_idx, varargin) 
% Plot autocorrelation of specified cell inside and outside opto stim
% epochs
    [ccginout] = getCCGinout(basePath, spikes, pulseEpochs_exper); %I changed this function to have spikes as an input
    plot(ccginout.ccgIN(:,cell_idx, cell_idx)); %in pulse
    plot(ccginout.ccgOUT(:,cell_idx, cell_idx));  %out of pulse
    
% Run CellExplorer
    

%% Virtual Reality
      cell_idx = 1;
%sanity check - do not quite get how
%     [SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin_VR, spikes)
%     plot(SpkTime{2}, SpkVoltage{2})
    
% Get the corresponding voltage position of each spike timestamp
      [spkEpVoltIdx] = getWheelPositionPerSpike(basePath, tr_ep);
% Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin) **FIGURE OUT CM OF TRACK VR*
      getPlaceField_VR(basePath, spkEpVoltage, tr_ep);
% Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)
    getPopulationPlaceField_VR(basePath, spkEpVoltage, tr_ep)
         
 % Colorful Raster of all cells over position (y trials, x position) dots different color for
 % different cells
    getRasterOverPosition(spikes, VR_BL1_Trials);
    getRasterOverPosition(spikes, VR_VR_Trials);
    getRasterOverPosition(spikes, VR_BL2_Trials);
        
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
 %run over dlc - get estimated position with timestamps
 %have a raster plot above the video with cells on y axis, and position on
 %x axis - dots appear when the cell fires for 1 second
 

 %%%%%%%%%%%%%%%%%%% Virtual Reality %%%%%%%%%%%%%%%%%%%%%%%%%

 
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


