function [numRipples, rippleTimestamps, rippleLength] = getNumAndLength_Ripples(Time, ripples)
% Purpose: find the number of ripples that occur between a start and stop
% time. Also make a matrix of each start and stop time of the ripples that
% fall inside the start and stop time.

% Input: Time   (struct with start and stop times of a segment of time)
%        ripples (struct with timestamps, peaks, stdev, peakNormedPower)

%Output: numRipples (number of ripples in the time segment)
%        rippleTimestamps (start and stop times of the ripples in this time
%        segment)
%        rippleLength (length of each ripple in a vector)

%% 
% find start and stop times of rippples that fall in the specified time
% range
  rippleTimestamps(:,1) = ripples.timestamps(find((ripples.timestamps(:,1) >= Time.start ...
                                                 & ripples.timestamps(:,1) <= Time.stop) ...
                                                & (ripples.timestamps(:,2) >= Time.start ...
                                                 & ripples.timestamps(:,2) <= Time.stop)),1);
  rippleTimestamps(:,2) = ripples.timestamps(find((ripples.timestamps(:,1) >= Time.start ...
                                             & ripples.timestamps(:,1) <= Time.stop) ...
                                            & (ripples.timestamps(:,2) >= Time.start ...
                                             & ripples.timestamps(:,2) <= Time.stop)),2);
% find the number of ripples
   numRipples = size(rippleTimestamps,1);
% get length of all ripples
   rippleLength = rippleTimestamps(:,2)-rippleTimestamps(:,1);
end