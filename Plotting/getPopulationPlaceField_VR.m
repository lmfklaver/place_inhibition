function [] = getPopulationPlaceField_VR(basePath, spkEpVoltage, tr_ep, varargin)
% Purpose: See averaged activity of all cells over trials across spatial bins

% Input:  basePath: path with data
%         spkEpVoltage: voltage of wheel at each spike time
%         tr_ep: trial start and stop times (only input trials to run over)
%         length_cm_track: how long the running wheel track is in cm
%         
% Output: Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)

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
    avg_spk_ct_position = zeros(size(spikes.times,2),length(0:bin_voltage:max(analogin.pos))-1);
    for icell = 1:size(spikes.times,2) 
        spkCt_Position = zeros(length(tr_ep), length(0:bin_voltage:max(analogin.pos))-1);
     for itrial = 1:length(tr_ep)
      [count, edges] = histcounts(cell2mat(spkEpVoltage{icell}.trial(itrial)),0:bin_voltage:max(analogin.pos)); % 100 for each cm?
      %make the first row of the matrix equal to the spikes per spatial
      %bin just found
      spkCt_Position(itrial,:) = count; 
     end 
         avg_spk_ct_position(icell,:) = mean(spkCt_Position,1);
         %normalize for time spent in area
    end
     sorted_cells_by_ct = sortrows(avg_spk_ct_position);
     figure;
     imagesc(sorted_cells_by_ct);
     title('All Cells');
     ylabel('Cell Number');
     xlabel('Position (cm)');
end