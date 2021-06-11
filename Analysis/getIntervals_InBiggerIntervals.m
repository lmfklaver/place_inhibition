function [subset_intervals] = getIntervals_InBiggerIntervals(segmentIntervals, biggerInterval)

% Purpose: Find the start and stop of intervals that only fall within a
% certain amount of time

% Input: segmentIntervals (a matrix of start and stop times of smaller
%                         intervals)
%        biggerIntervals (a single struct with a .start and .stop time,this
%                         is the intervals in which you want to find all the smaller
%                          intervals within)

%Output: subset_intervlas ( a matrix of start and stop times of only the
%                          intervals that fall within the biggerInterval)
% Reagan 6/11/21

             subset_intervals(:,1) = segmentIntervals(find((segmentIntervals(:,1) >= biggerInterval.start ...
                                                  & segmentIntervals(:,1) <= biggerInterval.stop) ...
                                                 & (segmentIntervals(:,2) >= biggerInterval.start ...
                                                  & segmentIntervals(:,2) <= biggerInterval.stop)),1);
             subset_intervals(:,2) = segmentIntervals(find((segmentIntervals(:,1) >= biggerInterval.start ...
                                                  & segmentIntervals(:,1) <= biggerInterval.stop) ...
                                                 & (segmentIntervals(:,2) >= biggerInterval.start ...
                                                  & segmentIntervals(:,2) <= biggerInterval.stop)),2);
                                                              
end