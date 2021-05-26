function [fig, fr_position] = getPlaceField_VR(basePath,cell_idx, spkEpVoltage, tr_ep, len_ep,ts_ep, analogin_VR, varargin)

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
addParameter(p,'length_cm_track',236,@isnumeric);
addParameter(p,'cm_per_spatial_bin',1,@isnumeric);

parse(p,varargin{:});
basePath        = p.Results.basePath;
tr_ep           = p.Results.tr_ep;
spkEpVoltage    = p.Results.spkEpVoltage;
length_cm_track = p.Results.length_cm_track;
cm_per_spatial_bin = p.Results.cm_per_spatial_bin;
%%
    %want to only load in analogin for VR because - want to find max and
    %min of analogin signal (this is different when the unity maze is not
    %on)
        basename = bz_BasenameFromBasepath(basePath);
        %load([basename '_analogin_VR.mat']); %may adapt later BUT make sure the scale of analogin --> cm is still accurate.
    
    % find the spatial bin size in analogin values (depends on how many cm
    % you want in a spatial bin) ie. assiging each analogin value a cm value
         bin_voltage = ((max(analogin_VR.pos)-min(analogin_VR.pos))/length_cm_track)*cm_per_spatial_bin; 
    
    %make a position and time matrix: rows = # wheel trials, comlumns = # of
    %position spatial bins
         num_spatial_bins = length(min(analogin_VR.pos):bin_voltage:max(analogin_VR.pos))-1;
         spkCt_Position = zeros(length(tr_ep), num_spatial_bins);
         spkCt_Time = zeros(length(tr_ep), num_spatial_bins);
    %for each trial:        get how many spikes fall within each spatial bin
    %for each trial also:   find the correpsonding time to each edge spatial
    %                       bin from histcounts --> plug in time to inIntervals & see how many
    %                       time points fall within that time frame
    
    for itrial = 1:length(tr_ep)
    % find how many spikes are in each spatial bin
         [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),min(analogin_VR.pos):bin_voltage:max(analogin_VR.pos)); % 100 for each cm?
    %make the first row of the matrix equal to the spikes per spatial bin just found
         spkCt_Position(itrial,:) = count; 
    
    %find the corresponding time points to the edges of the spatial bins
        ts_of_edges = zeros(1,length(edges));
    % for every edge find where the voltage of the wheel equals the
    % edge voltage
        for iedge = 1:length(edges)
            % see if the edge is equal to any voltage points in the wheel
            % trial, if is not - make it equal to zero (have to round to
            % third decimal)
            if length(find(round(len_ep{itrial},3) == round(edges(iedge),3)))>0
              idx_spatial = find(round(len_ep{itrial},3) == round(edges(iedge),3));  
              idx_spatial_edge = idx_spatial(1);
              ts_of_edges(1, iedge) = ts_ep{itrial}(idx_spatial_edge);
            else
             ts_of_edges(1, iedge) = 0;
            end
        end
        
    % make a start and stop matrix corresponding with the spatial bin start
    % and stop points
        start_ts_edge = ts_of_edges(1:end-1);
        stop_ts_edge = ts_of_edges(2:end);
        ts_start_stop_edges = [start_ts_edge;stop_ts_edge]';
    % For each interval, find the amount of time spent in the spatial bin
        for iInterval = 1:length(ts_start_stop_edges)
            % If the start and stop both = 0, the animal spent no time in
            % this spatial bin (so time = 0), note: voltage of each wheel
            % lap is not exactly the same each time, so that is why this
            % happens
            if ts_start_stop_edges(iInterval,1)==0 & ts_start_stop_edges(iInterval,2)==0
                spkCt_Time(itrial,iInterval) = 0;
            else
                [status,ts_per_interval] = InIntervals(ts_ep{itrial},ts_start_stop_edges(iInterval,:));
                ts_per_bin = length(find(ts_per_interval ==1));
                %divide the number of timestamps during the interval by
                %30000, that's how many samples per second the wheel
                %voltage is
                spkCt_Time(itrial,iInterval) = ts_per_bin/30000; %how many seconds spend in this bin (30000 samples per second)
            end
        end
    end 
    fig = figure;
    %firing rate
    fr_position = spkCt_Position./spkCt_Time;
    zscored_fr_pos = zscore(fr_position, 0,2); %zscore each row
    imagesc(fr_position);
    h = colorbar;
    ylabel(h, 'Firing Rate')
    ylabel('Trial');
    xlabel('Position (cm)');
    num_ticks = 4;
    tick_ct = num_spatial_bins/num_ticks;
    xticks([tick_ct tick_ct*2 tick_ct*3 tick_ct*4 tick_ct*5 tick_ct*6]);
    bin_ct = length_cm_track/num_ticks;
    xticklabels({[(num2str(bin_ct))],[num2str(bin_ct*2)],[num2str(bin_ct*3)],[num2str(bin_ct*4)],[num2str(bin_ct*5)],...
                [num2str(bin_ct*6)]});
    title(['Place Field: Cell ' num2str(cell_idx)]);
    hold off;
    figure;
    imagesc(zscored_fr_pos);
    h2 = colorbar;
    ylabel(h2, 'Firing Rate')
    ylabel('Trial');
    xlabel('Position (cm)');
    title(['Place Field Zscored: Cell ' num2str(cell_idx)]);
end