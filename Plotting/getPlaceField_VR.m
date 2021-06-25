function [fig, zfig, fr_position] = getPlaceField_VR(cell_idx, spkEpVoltage, tr_ep, len_ep,ts_ep, varargin)
% PURPOSE
%          See activity of a singular cell over spatial bins, for many
%          trials. Make a place field for one cell.
% INPUTS   basePath            String : path with data
%          spkEpVoltage        Array  : voltage of wheel at each spike time
%          tr_ep               Matrix : trial start and stop times (only input trials to run over)
%          length_cm_track     Numeric: how long the running wheel track is in cm
%                                       (default = 236cm)
%          cm_per_spatial_bin  Numeric: how many cm to group in a spatial bin
%                                       (default = 1cm)
%          min_volt            Numeric: Minimum analogin value wheel
%                                       poisition can be (default = .78)
%          max_volt            Numeric: Maximum analogin value wheel
%                                       position can be (default = 2.55)
% NOTE
%          min_volt and max_volt are inputs because finding
%          max(analogin.pos) does NOT accurately give the min and max
% OUTPUT
%          Singular place field over many trials (x = position, y = trials, color =
%          spikes per spatial bin). Figure with and without zscoring.
% DEPENDENCIES
%          Buzcode             https://github.com/buzsakilab/buzcode
% EXAMPLE
%         [fig, zfig, fr_position] = getPlaceField_VR(icell, spkEpVoltage, tr_ep, len_ep, ts_ep, 'cm_per_spatial_bin',2);
% HISTORY
%          Reagan Bullins 05.04.2021

%% Input Parsers
p = inputParser;
addParameter(p,'tr_ep',tr_ep,@isnumeric);
addParameter(p,'spkEpVoltage',spkEpVoltage,@isnumeric); 
addParameter(p,'length_cm_track',236,@isnumeric); %length of unity maze in cm
addParameter(p,'cm_per_spatial_bin',1,@isnumeric);
addParameter(p,'min_volt',.78,@isnumeric); %analogin value when holding wheel at start
addParameter(p,'max_volt',2.55,@isnumeric); %analogin value when holding wheel at end

parse(p,varargin{:});
tr_ep              = p.Results.tr_ep;
spkEpVoltage       = p.Results.spkEpVoltage;
length_cm_track    = p.Results.length_cm_track;
cm_per_spatial_bin = p.Results.cm_per_spatial_bin;
min_volt           = p.Results.min_volt;
max_volt           = p.Results.max_volt;
%% Find the firing rate of the cell in each spatial bin for each trial
% Find the spatial bin size in analogin values (depends on how many cm
% you want in a spatial bin) ie. assiging each analogin value a cm value
     bin_voltage = ((max_volt-min_volt)/length_cm_track)*cm_per_spatial_bin;
     
% Make a position and time matrix: rows = # wheel trials, comlumns = # of
% position spatial bins
     num_spatial_bins = length(min_volt:bin_voltage:max_volt)-1;
     spkCt_Position = zeros(length(tr_ep), num_spatial_bins);
     spkCt_Time = zeros(length(tr_ep), num_spatial_bins);
%for each trial:        get how many spikes fall within each spatial bin
%for each trial also:   find the correpsonding time to each edge spatial
%                       bin from histcounts --> plug in time to inIntervals & see how many
%                       time points fall within that time frame   
    for itrial = 1:length(tr_ep)
        % find how many spikes are in each spatial bin
             [count, edges] = histcounts(cell2mat(spkEpVoltage{cell_idx}.trial(itrial)),min_volt:bin_voltage:max_volt); % 100 for each cm?
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
            if ts_start_stop_edges(iInterval,1)==0 && ts_start_stop_edges(iInterval,2)==0
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
%% Plot Place field
    fig = figure;
% Find firing rate by dividing each spatial bin number of spikes by
% time spent in that spatial bin
    fr_position = spkCt_Position./spkCt_Time;
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
%% Plot Place field zscored across trials (rows)
    zfig = figure;
    zscored_fr_pos = zscore(fr_position, 0,1); %zscore each row
    imagesc(zscored_fr_pos);
    h2 = colorbar;
    ylabel(h2, 'Firing Rate')
    ylabel('Trial');
    xlabel('Position (cm)');
    title(['Place Field Zscored: Cell ' num2str(cell_idx)]);
    num_ticks = 4;
        tick_ct = num_spatial_bins/num_ticks;
        xticks([tick_ct tick_ct*2 tick_ct*3 tick_ct*4 tick_ct*5 tick_ct*6]);
        bin_ct = length_cm_track/num_ticks;
        xticklabels({(num2str(bin_ct)),num2str(bin_ct*2),num2str(bin_ct*3),num2str(bin_ct*4),num2str(bin_ct*5),...
                    num2str(bin_ct*6)});
end