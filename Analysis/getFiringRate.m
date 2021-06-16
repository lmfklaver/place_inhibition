function [firingRateSegment] = getFiringRate(TimeInterval,cell_spikes) 

% Purpose: get firing rate of one cell, in a certain period of time.

% Inputs: TimeInterval - matrix of start and stop times
%         cell_spikes  

% Outputs: firing rate segment - spikes per second for one cell

    [status, ~] = InIntervals(cell_spikes,TimeInterval);
     spikesInSegment = sum(status);
     segmentTotalTime = sum(TimeInterval(:,2) - TimeInterval(:,1));
     firingRateSegment = spikesInSegment/segmentTotalTime;
     
end