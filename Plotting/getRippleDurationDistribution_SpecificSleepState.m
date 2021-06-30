function [rippleDistribution] = getRippleDurationDistribution_SpecificSleepState(specificSleepState, Time, ripples, varargin)
% PURPOSE
%          Make a ripple duration distribution (histogram) for a specifc
%          state of sleep (Wake, NREM, or REM). Seperate each of the sleep sessions.
%
% INPUTS
%          Time                  Struct: Struct with other structs for stop and start times of segment
%              .Sleep1.start
%              .Sleep1.stop
%              ...n sleeps
%          specificSleepState    Matrix: start and stop times of specific state
%                                Either input: SleepState.ints.NREMstate..REMstate...WAKEstate
%          ripples               Struct: ripples.timestamps, start and stop of ripples
%              .timestamps
%
% OUTPUT
%          rippleDistribution    Matrix: (# sleep segments X length(bin_length)) 
%                                        Distribution of ripple lengths
%          Distribution of ripples per duration length (y = ripple ratio
%         (count divided by all ripples), x = ripple duration, color = sleep
%          session)
% DEPENDENCIES
%          Buzcode               https://github.com/buzsakilab/buzcode
%          Place Inhibition      https://github.com/rcbullins/place_inhibition
% HISTORY
%          Reagan Bullins 06.12.2021
%% Input Parsers
p = inputParser;
addParameter(p,'bin_length',(0:.006:.3),@isvector);
parse(p,varargin{:});
bin_length       = p.Results.bin_length;

%% 
% Make sleep colors (warm colors, as in other functions in Place
% Inhibition)
    warm_colors = hot(20);
    sleep_colors = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];
% Want to plot for how many sleep segments there are
    stringFields = fieldnames(Time);
    Index_Sleep = find(contains(stringFields,'Sleep'));
% For each sleep, find the numer of ripples and the length of each ripple
    rippleDistribution = zeros(length(Index_Sleep),length(bin_length));
    for isleep = 1:length(Index_Sleep)
         % find all specific sates into each sleep segment
              Time_StartStop = Time.(stringFields{Index_Sleep(isleep)});
              [sleep_intervals] = getIntervals_InBiggerIntervals(specificSleepState, Time_StartStop);
         % find how many ripples happen in each segment
              [sleep_logical, ~, ~] = InIntervals(ripples.timestamps,  sleep_intervals);
              S_ripples = ripples.timestamps(sleep_logical,:);
              [numRipples,rippleLength] = getNumAndLength_Ripples(S_ripples);
         % make histogram of ripple length      
              [count,~] = hist(rippleLength,bin_length);
              % divide the number of each ripple length by the total number
              % of ripples
               plot(count ./numRipples, 'Color',sleep_colors(isleep,:));
               rippleDistribution(isleep, :) = count ./numRipples;
               
               hold on;
               legend_info{isleep} = ([stringFields{Index_Sleep(isleep)} ':' num2str(numRipples)]);
    end
% Add graph specs
    xticks([0 10 20 30 40 50]);
    xticklabels({'0',num2str(bin_length(10)),num2str(bin_length(20)),num2str(bin_length(30)),...
                     num2str(bin_length(40)),num2str(bin_length(50))});
    xlabel('Ripple Length (s)');
    ylabel('Ripple ratio');
    legend(legend_info);
        
end