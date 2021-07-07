function [] = getPopulationPlaceField_VR(basePath, tr_ep, len_ep, ts_ep, spikes, analogin_VR,analogin,varargin)
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
addParameter(p,'length_cm_track',236,@isnumeric);
addParameter(p,'cm_per_spatial_bin',1,@isnumeric);

parse(p,varargin{:});
basePath        = p.Results.basePath;
tr_ep           = p.Results.tr_ep;
length_cm_track = p.Results.length_cm_track;
cm_per_spatial_bin = p.Results.cm_per_spatial_bin;
%%
     [spkEpVoltIdx, spkEpVoltage] = getWheelPositionPerSpike(basePath, tr_ep, analogin,spikes);
      basename = bz_BasenameFromBasepath(basePath);
      %load([basename '.spikes.cellinfo.mat']);
      %load([basename '_analogin_VR.mat']); %may adapt later BUT make sure the scale of analogin --> cm is still accurate.

     bin_voltage = ((max(analogin_VR.pos)-min(analogin_VR.pos))/length_cm_track)*cm_per_spatial_bin; 
     num_spatial_bins = length(min(analogin_VR.pos):bin_voltage:max(analogin_VR.pos))-1; 
     
     pop_fr_pos = zeros(size(spikes.times,2), num_spatial_bins);
for icell = 1:size(spikes.times,2) 
      [fig, fr_position] = getPlaceField_VR(basePath, icell, spkEpVoltage, tr_ep, len_ep, ts_ep, analogin_VR);
      cd('/home/reagan4/Results/PI_Results');
      savefig(['Cell' num2str(icell) '_PlaceField.fig'], '-v7.3')
      delete(fig);
      pop_fr_pos(icell,:) = mean(fr_position,1);
end
      cd('/home/reagan4/Results/PI_Results');
      figure;
      imagesc(pop_fr_pos);
      hold on;
      title('All Cells: not sorted');
      ylabel('Cell Number');
      xlabel('Position (cm)');
      savefig('Population_PlaceField.fig', '-v7.3');
      hold off;
      figure;
      imagesc(sortrows(pop_fr_pos));
      hold on;
      title('All Cells: sorted');
      ylabel('Cell Number');
      xlabel('Position (cm)');
      savefig('Population_PlaceField_Sorted.fig', '-v7.3');
      hold off;
      figure
      zscore_pop = zscore(pop_fr_pos,0,2);
      imagesc(sortrows(zscore_pop));
      hold on;
      title('All Cells: zscore and sorted');
      ylabel('Cell Number');
      xlabel('Position (cm)');
      savefig('Population_PlaceField_Sorted_Zscored.fig', '-v7.3');
      hold off;
     save('Pop_FR_position.mat','pop_fr_pos', '-v7.3');
  
  
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