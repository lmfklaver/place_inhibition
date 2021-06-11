% Reagans preprocessing pipeline
% Run Once After Obtaining Data - For all experimental setups
%%
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
%   Matlab script : RecordingDirectory_PlaceTuning

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
    
% getAnaloginVals (make sure xml is 8 channels, 30000Hz)
        % wheel = 5,blinklight = 6
    analogin = getAnaloginVals(basePath,'wheelChan',5,'pulseChan','none','rewardChan','none','blinkChan',6, 'downsampleFactor',100);
    
% getDigitalinVals (4= reward, 2 = stim)
    fileinfo = dir(fullfile([basename '_digitalin.dat']));
    num_samples = fileinfo.bytes/2 ; % uint16 = 2 bytes
    fid = fopen([basename '_digitalin.dat'], 'r');
    digital_word = fread(fid, num_samples, 'uint16');
    fclose(fid);
    digital_input_stim = (bitand(digital_word, 2^2) > 0); % ch # goes after the 2^
    digital_input_reward = (bitand(digital_word, 2^4) > 0);
    
    save([basename '_digitalin.analysis.mat'], 'digital_input_reward', 'digital_input_stim')
    %makePulseFile
% getPulseEpochs % get optoStim
    digitalin.ts = analogin.ts;
    digitalin.pulse = digital_input_stim;
    pulseEpochs = getPulseTimes(digitalin); %epochs in seconds
    
    save([basename '_pulseEpochs.analysis.mat'],'pulseEpochs');
%turn pulseEpochs in basename.optostim.manipulation.mat for CellExplorer
% Get Spikes
    spikes = bz_GetSpikes;
    
