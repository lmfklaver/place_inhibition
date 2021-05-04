function [] = getPlaceField_VR(basePath, spkEpVoltage, tr_ep, varargin)

% Purpose: See activity of a singular cell over spatial bins, for many
% trials

% Input:  basePath: path with data
%         spkEpVoltage: voltage of wheel at each spike time
%         tr_ep: trial start and stop times (only input trials to run over)
%         length_cm_track: how long the running wheel track is in cm
%         
% Output: Singular place field over many trials (x = position, y = trials, color =
% spikes per spatial bin)

% Reagan 2021.05.04

%%
p = inputParser;
addParameter(p,'basePath',basePath,@isstr);
addParameter(p,'tr_ep',tr_ep,@isnumeric);
addParameter(p,'spkEpVoltage',spkEpVoltage,@isnumeric);
addParameter(p,'length_cm_track',100,@isnumeric);

parse(p,varargin{:});
basePath        = p.Results.basePath;
tr_ep           = p.Results.tr_ep;
spkEpVoltage    = p.Results.spkEpVoltage;
length_cm_track = p.Results.length_cm_track;
%%
    basename = bz_BasenameFromBasepath(basePath);
    load([basename '_analogin.mat']);
    
    bin_voltage = max(analogin.pos)/length_cm_track; 
    
    spkCt_Position = zeros(length(tr_ep), length(0:bin_voltage:max(analogin.pos))-1);
    for itrial = 1:length(tr_ep)
    [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),0:bin_voltage:max(analogin.pos)); % 100 for each cm?
    %make the first row of the matrix equal to the spikes per spatial
    %bin just found
    spkCt_Position(itrial,:) = count; 
    end 
    figure;
    imagesc(spkCt_Position);
    ylabel('Trial');
    xlabel('Position (cm)');
    title(['Place Field: Cell ' num2str(cell_idx)]);
end