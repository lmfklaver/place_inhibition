function [] = getPopulationPlaceField_VR(basePath, tr_ep, len_ep, ts_ep, varargin)
% Purpose: See averaged activity of all cells over trials across spatial bins

% Input:  basePath: path with data
%         spkEpVoltage: voltage of wheel at each spike time
%         tr_ep: trial start and stop times (only input trials to run over)
%         length_cm_track: how long the running wheel track is in cm
%         
% Output: Multiple place cells averaged over multiple trials (x = position, y =
% cell, color = averaged over trials spikes per spatial bin)

% Reagan 2021.05.04

%% Parser Inputs
p = inputParser;
addParameter(p,'basePath',basePath,@isstr);
addParameter(p,'tr_ep',tr_ep,@isnumeric);
addParameter(p,'length_cm_track',236,@isnumeric);
addParameter(p,'cm_per_spatial_bin',1,@isnumeric);

parse(p,varargin{:});
basePath           = p.Results.basePath;
tr_ep              = p.Results.tr_ep;
length_cm_track    = p.Results.length_cm_track;
cm_per_spatial_bin = p.Results.cm_per_spatial_bin;
%% Load in variables
    % Get the position of the wheel at every spike time
      [spkEpVoltIdx, spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep);
      basename = bz_BasenameFromBasepath(basePath);
      load([basename '.spikes.cellinfo.mat']);
      load([basename '_analogin_VR.mat']); %may adapt later BUT make sure the scale of analogin --> cm is still accurate.
   
%% Find mean firing rate per spatial bin for all cells 
    % Find the voltage step you want to take to define your spaital bins
    % - Find the max and min of the analogin during virtual reality, and
    % divide it evenly with the length of the virtual reality track
        bin_voltage = ((max(analogin_VR.pos)-min(analogin_VR.pos))/length_cm_track)*cm_per_spatial_bin; 
        num_spatial_bins = length(min(analogin_VR.pos):bin_voltage:max(analogin_VR.pos))-1; 
    % Initialize a matrix to store the average firing rate for each cell in each spatial bin (rows = cells, columns = spatial bins) 
        pop_fr_pos = zeros(size(spikes.times,2), num_spatial_bins);
    % For Every cell, find the firing rate in each spatial bin for all
    % trials, graph it, and save the figure
        for icell = 5:size(spikes.times,2) 
              [fig, fr_position] = getPlaceField_VR(basePath, icell, spkEpVoltage, tr_ep, len_ep, ts_ep, analogin_VR);
              cd([basePath '/Figures/PlaceFields']);
              savefig(fig,['Cell' num2str(icell) '_PlaceField.fig'])
              delete(fig);
              pop_fr_pos(icell,:) = mean(fr_position);
              cd([basePath]);
        end
%% Plot population figures
        cd([basePath '/Figures/PlaceFields']);
        figure;
    % Make all the nan values = 0 (voltages that did not exist in some
    % laps)
        pop_fr_pos(isnan(pop_fr_pos))=0; 
        imagesc(pop_fr_pos);
        hold on;
        title('All Cells: not sorted');
        ylabel('Cell Number');
        xlabel('Position (cm)');
        savefig('Population_PlaceField.fig');
        hold off;
    % Make a figure with the population data sorted
        figure;
        imagesc(sortrows(pop_fr_pos));
        hold on;
        title('All Cells: sorted');
        ylabel('Cell Number');
        xlabel('Position (cm)');
        savefig('Population_PlaceField_Sorted.fig');
        hold off;
    % Make a figure of the zscored population graph
        figure
        zscore_pop = zscore(pop_fr_pos,0,2);
        imagesc(sortrows(zscore_pop));
        hold on;
        title('All Cells: zscore and sorted');
        ylabel('Cell Number');
        xlabel('Position (cm)');
        savefig('Population_PlaceField_Sorted_Zscored.fig');
        hold off;
        save('Pop_FR_position.mat','pop_fr_pos');
  
%% Original - not time including
%     basename = bz_BasenameFromBasepath(basePath);
%     load([basename '_analogin.mat']);
%   
%     bin_voltage = max(analogin.pos)/length_cm_track; 
%     avg_spk_ct_position = zeros(size(spikes.times,2),length(0:bin_voltage:max(analogin.pos))-1);
%     for icell = 1:size(spikes.times,2) 
%         spkCt_Position = zeros(length(tr_ep), length(0:bin_voltage:max(analogin.pos))-1);
%      for itrial = 1:length(tr_ep)
%       [count, edges] = histcounts(cell2mat(spkEpVoltage{icell}.trial(itrial)),0:bin_voltage:max(analogin.pos)); % 100 for each cm?
%       %make the first row of the matrix equal to the spikes per spatial
%       %bin just found
%       spkCt_Position(itrial,:) = count; 
%      end 
%          avg_spk_ct_position(icell,:) = mean(spkCt_Position,1);
%          %normalize for time spent in area
%     end
%      sorted_cells_by_ct = sortrows(avg_spk_ct_position);
%      figure;
%      imagesc(sorted_cells_by_ct);
%      title('All Cells');
%      ylabel('Cell Number');
%      xlabel('Position (cm)');
end