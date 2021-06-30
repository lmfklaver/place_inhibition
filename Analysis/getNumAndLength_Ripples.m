function [numRipples, rippleLength] = getNumAndLength_Ripples(rippleTimestamps)
% Purpose: find the number of ripples that occur between a start and stop
% time. Also make a matrix of each start and stop time of the ripples that
% fall inside the start and stop time.

% Input:
%        ripples (matrix of start and stop times of each ripple numRip X2)

%Output: numRipples (number of ripples in the time segment)
%        segment)
%        rippleLength (length of ripples within segment)

% find the number of ripples
   numRipples = size(rippleTimestamps,1);
% find length of ripples in segment
   rippleLength = rippleTimestamps(:,2)-rippleTimestamps(:,1);
end