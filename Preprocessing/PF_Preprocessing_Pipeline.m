function [] = PF_Preprocessing_Pipeline(basePath, runKilosort, spikeSorted)
% PURPOSE 
%          Run basic preprocessing steps:
%              Run data over kilosort (if runKilosort is true), get spikes 
%              (if spike sorted), get lfp (if file does not exist)...
%              get digitalin values and analogin values (if files do not
%              exist)
% INPUTS   
%          basePath        String : Dir with data
%          runKilosort     Boolean: if true, the data should be ran over
%                                  kilosort
%          spikeSorted     Boolean: if true, the data is spike sorted
% OUTPUTS 
%          kilosort files
%          spikes struct
%          lfp file
%          session info mat
%          analogin mat
%          digitalin mat
%          pulse epochs mat 
% DEPENDENCIES
%          Buzcode         https://github.com/buzsakilab/buzcode
%           
% NOTE    
%          Can Run this script if you have some of these things already ran,
%          this script checks to see if there is an existing file or not.
%          If the file already exists, the script skips making it again.
% HISTORY 
%          Reagan Bullins 03.14.2021 
%% Get basename
    basename = bz_BasenameFromBasepath(basePath);
%% Run Kilosort (if runKilosort = true)

    if strcmp(runKilosort, 'true')
       % Run Kilosort2 (updatepath rootZ first with datapath!)
        tic, master_kilosort_reaganp1,toc;% so you know how long it takes
    end
%%  Get spikes (if it has been spike sorted)   
    if strcmp(spikeSorted, 'true') && ~isfile([basename '.spikes.cellinfo.mat'])
        bz_GetSpikes;
    end
    
%% Get LFP, analogin and digitalin values
    cd(basePath);
% Get SessionInfo, if it isn't already a file
    if ~isfile([basename '.sessioninfo.mat'])
        bz_getSessionInfo;
    end
% Get lfp, if it isn't already a file
    if ~isfile([basename '.lfp'])
        bz_LFPfromDat(basePath);
    end
    
% Get Analogin Values (make sure xml is 8 channels, 30000Hz)
        % wheel = 5,blinklight = 6
    if ~isfile([basename '_analogin.mat'])
        analogin = getAnaloginVals(basePath,'wheelChan',5,'pulseChan','none','rewardChan','none','blinkChan',6, 'downsampleFactor',100);
    end
    
% Get Digitalin Valuess (4= reward, 2 = stim)
    if ~isfile([basename '_digitalin.analysis.mat'])
        fileinfo = dir(fullfile([basename '_digitalin.dat']));
        num_samples = fileinfo.bytes/2 ; % uint16 = 2 bytes
        fid = fopen([basename '_digitalin.dat'], 'r');
        digital_word = fread(fid, num_samples, 'uint16');
        fclose(fid);
        digital_input_stim = (bitand(digital_word, 2^2) > 0); % ch # goes after the 2^
        digital_input_reward = (bitand(digital_word, 2^4) > 0);

        save([basename '_digitalin.analysis.mat'], 'digital_input_reward', 'digital_input_stim');
    end
    
% Get Pulse Epochs/Opto stim
    if ~isfile([basename '_pulseEpochs.analysis.mat'])
        load([basename '_analogin.mat']);
        load([basename '_digitalin.analysis.mat']);
        digitalin.ts = analogin.ts;
        digitalin.pulse = digital_input_stim;
        
        pulseEpochs = getPulseTimes(digitalin); %epochs in seconds

        save([basename '_pulseEpochs.analysis.mat'],'pulseEpochs');
        %turn pulseEpochs in basename.optostim.manipulation.mat for CellExplorer
    end
end