function[] = getSpikePositionPlot(cell_idx,spikes,Vtracking,Time)
% PURPOSE
%          Make a plot for one cell, the plot will have dot at the x and y posision where the
%          cell fired (for open field or linear track or any freely moving)
% INPUT    spikes        Struct: with spiking times
%          Vtracking     Struct: with frame times, xposition, and y position(from AlignVidDLC)
%          Time          Struct: struct with start and stop time of segment
% OUTPUT
%          x and y plot, with dots where the specified cell fired
% DEPENDENCIES
%          Output from AlignVidDLC (Kaiser's Dev branch in
%          https://github.com/englishneurolab/utilities)
% HISTORY
%          Reagan Bullins 06.16.2021

%% 
    % Get position of each frame of the video 
        x_pos = Vtracking.xpos;
        y_pos = Vtracking.xpos;
        positionTimes = Vtracking.frameTimes(:,1);
    % find spikes that occur in the given time segment
        spikes_interval = spikes.times{cell_idx}(spikes.times{cell_idx}> Time.start & spikes.times{cell_idx} < Time.stop);
    % find spikes in each frame of the video
        positionTimes_startstop(:,1) = positionTimes(1:end-1,:);
        positionTimes_startstop(:,2) = positionTimes(2:end,:);
        figure;
        for ispike = 1:length(spikes_interval)
            % find the position of each spike
            interval_pos = find(positionTimes_startstop(:,1) <= spikes_interval(ispike) & positionTimes_startstop(:,2) >= spikes_interval(ispike));
            % plot the position of each spike as a dot
            plot(x_pos(interval_pos,1),y_pos(interval_pos,1),'.r');
            hold on;
        end 
end