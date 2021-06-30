function [subset_intervals] = getIntervals_InBiggerIntervals(segmentIntervals, biggerInterval)
% PURPOSE
%          Find the start and stop of intervals that only fall within a
%          certain amount of time
% INPUTS
%          segmentIntervals      Matrix: start and stop times of smaller
%                                        intervals (n x 2)
%          biggerIntervals       Struct: .start and .stop time,this
%                                        is the intervals in which you want 
%                                        to find all the smaller intervals within)
% OUTPUT
%          subset_intervlas      Matrix: start and stop times of only the
%                                        intervals that fall within the biggerInterval
% HISTORY
%          Reagan 06.11.2021
%%
             subset_intervals(:,1) = segmentIntervals(find((segmentIntervals(:,1) >= biggerInterval.start ...
                                                  & segmentIntervals(:,1) <= biggerInterval.stop) ...
                                                 & (segmentIntervals(:,2) >= biggerInterval.start ...
                                                  & segmentIntervals(:,2) <= biggerInterval.stop)),1);
             subset_intervals(:,2) = segmentIntervals(find((segmentIntervals(:,1) >= biggerInterval.start ...
                                                  & segmentIntervals(:,1) <= biggerInterval.stop) ...
                                                 & (segmentIntervals(:,2) >= biggerInterval.start ...
                                                  & segmentIntervals(:,2) <= biggerInterval.stop)),2);                                                          
end