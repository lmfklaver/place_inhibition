function [] = getPlaceField_FreelyMoving(basePath, cell_idx, Vtracking, Time,setupDimensions, varargin)

% Purpose: See activity of a singular cell over spatial bins, for many
% trials

% Input:  basePath: path with data
%         Vtracking: struct with x and y position, and corresponding time
%         cell_idx: which cell to make a place field for
%         setupDimensions: struct of x and y length (in centimeters)
%         
% Output: Singular place field over many trials (x = x position, y = y position, color =
% spikes per spatial bin)

% Reagan 2021.06.16

%% Input Parsers
p = inputParser;
addParameter(p,'cm_per_spatial_bin',1,@isnumeric);

parse(p,varargin{:});
cm_per_spatial_bin = p.Results.cm_per_spatial_bin;
%% Find the firing rate of the cell in each spatial bin for each trial
    % Find the spatial bin size in pixels values (depends on how many cm
    % you want in a spatial bin) ie. assiging each analogin value a cm value
         bin_voltage_x = ((max(Vtracking.xpos)-min(Vtracking.xpos))/setupDimensions.xlength)*cm_per_spatial_bin;
         bin_voltage_y = ((max(Vtracking.ypos)-min(Vtracking.ypos))/setupDimensions.ylength)*cm_per_spatial_bin;
    % Make a position and time matrix: spatial bins (x = xposition, y =
    % yposition)
         num_spatial_bins_x = length(min(Vtracking.xpos):bin_voltage_x:max(Vtracking.xpos))-1;
         num_spatial_bins_y = length(min(Vtracking.ypos):bin_voltage_y:max(Vtracking.ypos))-1;
         spkCt_Position = zeros(length(tr_ep), num_spatial_bins_x);
         spkCt_Time = zeros(length(tr_ep), num_spatial_bins_x);
         
    %for each trial:        get how many spikes fall within each spatial bin
    %for each trial also:   find the correpsonding time to each edge spatial
    %                       bin from histcounts --> plug in time to inIntervals & see how many
    %                       time points fall within that time frame
         % Plot of cell firing in open field
            x_pos = Vtracking.xpos;
            y_pos = Vtracking.xpos;
            positionTimes = Vtracking.frameTimes(:,1);
            spikes_interval = spikes.times{cell_idx}(spikes.times{cell_idx}> Time.start & spikes.times{cell_idx} < Time.stop);
        % find spikes in intervals
            positionTimes_startstop(:,1) = positionTimes(1:end-1,:);
            positionTimes_startstop(:,2) = positionTimes(2:end,:);
            figure;
            for ispike = 1:length(spikes_interval)
                interval_pos = find(positionTimes_startstop(:,1) <= spikes_interval(ispike) & positionTimes_startstop(:,2) >= spikes_interval(ispike));
                plot(x_pos(interval_pos,1),y_pos(interval_pos,1),'.r');
                hold on;
            end 
     
            % find how many spikes are in each spatial bin
                 [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),min_volt:bin_voltage_x:max_volt); % 100 for each cm?
                 % make the itrial row of the matrix equal to the spikes per
            % spatial bin just found for this trial
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
                     ts_of_edges(1, iedge) = 0; %if it falls outside of min volt or max volt discard
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
    
%% Plot
        fig = figure;
    % Find firing rate by dividing each spatial bin number of spikes by
    % time spent in that spatial bin
        fr_position = spkCt_Position./spkCt_Time;
        zscored_fr_pos = zscore(fr_position, 0,1); %zscore each row
        imagesc(fr_position);
        h = colorbar;
        ylabel(h, 'Firing Rate')
        ylabel('Trial');
        xlabel('Position (cm)');
        num_ticks = 4;
        tick_ct = num_spatial_bins_x/num_ticks;
        xticks([tick_ct tick_ct*2 tick_ct*3 tick_ct*4 tick_ct*5 tick_ct*6]);
        bin_ct = length_cm_track/num_ticks;
        xticklabels({[(num2str(bin_ct))],[num2str(bin_ct*2)],[num2str(bin_ct*3)],[num2str(bin_ct*4)],[num2str(bin_ct*5)],...
                    [num2str(bin_ct*6)]});
        title(['Place Field: Cell ' num2str(cell_idx)]);
        hold off;
   zfig = figure;
    imagesc(zscored_fr_pos);
    h2 = colorbar;
    ylabel(h2, 'Firing Rate')
    ylabel('Trial');
    xlabel('Position (cm)');
    title(['Place Field Zscored: Cell ' num2str(cell_idx)]);
    num_ticks = 4;
        tick_ct = num_spatial_bins_x/num_ticks;
        xticks([tick_ct tick_ct*2 tick_ct*3 tick_ct*4 tick_ct*5 tick_ct*6]);
        bin_ct = length_cm_track/num_ticks;
        xticklabels({[(num2str(bin_ct))],[num2str(bin_ct*2)],[num2str(bin_ct*3)],[num2str(bin_ct*4)],[num2str(bin_ct*5)],...
                    [num2str(bin_ct*6)]});
end