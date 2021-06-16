function[] = getSpikePositionPlot(cell_idx,spikes,Vtracking,Time)
% Purpose: make a plot for one cell, the plot will have dot at the x and y posision where the
% cell fired (for open field or linear track or any freely moving)

% Input: spikes struct
%        Vtracking (from AlignVidDLC)
%        Time      (struct with start and stop time of segment)

% Output:Plot where specified cell fired

% Reagan 6/16/21

%% 
    % Plot of cell firing in open field
        x_pos = Vtracking.xpos;
        y_pos = Vtracking.xpos;
        positionTimes = Vtracking.frameTimes(:,1);
    % convert positionTimes to seconds
       % [positionTimes_seconds] = convertVideoPositionTime_2Seconds(positionTimes);
    % find spikes that occur in the open field
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
end