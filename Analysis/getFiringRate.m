function [firingRateSegment] = getFiringRate(Time,cell_spikes) 

% Purpose: get firing rate of one cell, in a certain period of time.

% Inputs: Time - Start and stop struct
%         cell_spikes  

% Outputs: firing rate segment - spikes per second for one cell

    [status, edges] = InIntervals(cell_spikes,[Time.start Time.stop]);
     spikesInSegment = sum(status);
     segmentTotalTime = Time.stop - Time.start;
     firingRateSegment = spikesInSegment/segmentTotalTime;
     
end