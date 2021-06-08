function [SleepState, inputData] = PF_Preprocessing_SleepValidation(basePath, chans2check, Time_start, Time_stop)
%Sleep Validation

%Purpose:
%       Validate all sleep sessions to determine when the animal was
%       sleeping in it's home cage versus moving around.

%Inputs:
%       auxilary: 3 channels, 30000
%       basePath: path with lfp file and all other data 
%       chans2check: 3 lfp channels to check emg over - top channel, best rip chan, bottom channel
%       Time: Time of sleep segment you want to test

%Outputs:
%       SleepState: Start and stop times of sleep
%       InputData:  Data strucutre needed to use the sleep editor to visualize how well
%                   the sleep data was seperated
% sanity checks to do:
%       accelerometer signal (sanity check after sleep score)
%       use video (sanity check - dlc position - find velocity)
% To DO:
%       check units on auxiliary
%.motion : use accelmotorer channel or video (ds to 1 Hz)

% Code from Kaiser and Lianne, adapted by Reagan 6/3/21

%% State scoring
cd(basePath);
load('chanMap.mat');
rejectChannels = chanMap(find(connected == 0));
EMGFromLFP = bz_EMGFromLFP(basePath)
SleepState = SleepScoreMaster(cd,'scoretime', [Time_start Time_stop],'overwrite', true, ...
    'rejectChannels', rejectChannels)% exclude the times of stimulation
%% Make input struct for the state editor (analogin motion)
basename = bz_BasenameFromBasepath(cd)
lfp = bz_GetLFP(chans2check) 
x = ones(1,3);
inputData.rawEeg = mat2cell(double(lfp.data),length(lfp.data),x)
inputData.eegFS = 1
inputData.Chs = lfp.channels
inputData.MotionType = 'File'
%WHAT TO PUT HERE?
inputData.motion = double(bz_LoadBinary([basename '_auxiliary.dat'],'nChannels', 3, 'channels', 1, 'precision', 'uint16', 'downsample', 30000)) %* 0.000050354; %state editor motion needs data in a one hz format
% inputData.motion(end) = []; % this may be needed if you run into an error
% on line 983
clear lfp
%TheStateEditor(basename, inputData) % this is the manual state editor, use to check the automation of the sleepscoremaster
% for troublshooting with Lianne
% inputData.motion = downsample(analogin.pos,30000)
inputData.motion(end) = []; % delete basename.eegstates.mat before rerunning the editor
end