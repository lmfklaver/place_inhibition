function [rippleDistribution] = getRippleDurationDistribution_ExpPostSleep(specificSleepState, Time, ripples, varargin)
% PURPOSE
%          Make a ripple duration distribution (histogram) for a specifc
%          state of sleep (Wake, NREM, or REM).For each sleep following VR,
%          OF, LT
%
% INPUTS
%          Time                  Struct: Struct with other structs for stop and start times of segment
%              .Sleep1.start              4 sleeps, and 3 experiment
%                                          segments
%              .Sleep1.stop
%              ...n segments
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
% Make sleep colors (warm colors, as in other functions in Place
% Inhibition)
    cool_colors =cool(20);
    exp_colors = [cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);cool_colors(12,:)];
% Find order of experiment
    [exper_order] = getExperimentalOrder_PlaceInhibition(Time);
% For each postsleep, find the numer of ripples and the length of each ripple
    rippleDistribution = zeros(length(exper_order),length(bin_length));
    % for each experiment (in order of what it occured), find the post
    % sleep
    sleep_order = {'Sleep2';'Sleep3';'Sleep4'};
% For VR
         % find all specific sates in sleep after VR
              VR_idx = find(strcmp(exper_order,'VR'));
              Time_StartStop_VR = Time.(sleep_order{VR_idx});
              [sleepVR_intervals] = getIntervals_InBiggerIntervals(specificSleepState, Time_StartStop_VR);
         % find how many ripples happen in each segment
              [sleep_logical_VR, ~, ~] = InIntervals(ripples.timestamps,  sleepVR_intervals);
              VR_ripples = ripples.timestamps(sleep_logical_VR,:);
              [numRipples_VR,rippleLength_VR] = getNumAndLength_Ripples(VR_ripples);
         % make histogram of ripple length      
              [count_VR,~] = hist(rippleLength_VR,bin_length);
              % divide the number of each ripple length by the total number
              % of ripples
               plot(count_VR ./numRipples_VR, 'Color', exp_colors(1,:));
               rippleDistribution(1, :) = count_VR ./numRipples_VR;
               
               hold on;
               legend_info{1} = (['VR - ' sleep_order{VR_idx} ':' num2str(numRipples_VR)]);
% For OF
         % find all specific sates in sleep after VR
              OF_idx = find(strcmp(exper_order,'OF'));
              Time_StartStop_OF = Time.(sleep_order{OF_idx});
              [sleepOF_intervals] = getIntervals_InBiggerIntervals(specificSleepState, Time_StartStop_OF);
         % find how many ripples happen in each segment
              [sleep_logical_OF, ~, ~] = InIntervals(ripples.timestamps,  sleepOF_intervals);
              OF_ripples = ripples.timestamps(sleep_logical_OF,:);
              [numRipples_OF,rippleLength_OF] = getNumAndLength_Ripples(OF_ripples);
         % make histogram of ripple length      
              [count_OF,~] = hist(rippleLength_OF,bin_length);
              % divide the number of each ripple length by the total number
              % of ripples
               plot(count_OF ./numRipples_OF, 'Color',exp_colors(2,:));
               rippleDistribution(2, :) = count_OF ./numRipples_OF;
               
               hold on;
               legend_info{2} = (['OF - ' sleep_order{OF_idx} ':' num2str(numRipples_OF)]);
% For LT
         % find all specific sates in sleep after VR
              LT_idx = find(strcmp(exper_order,'LT'));
              Time_StartStop_LT = Time.(sleep_order{LT_idx});
              [sleepLT_intervals] = getIntervals_InBiggerIntervals(specificSleepState, Time_StartStop_LT);
         % find how many ripples happen in each segment
              [sleep_logical_LT, ~, ~] = InIntervals(ripples.timestamps,  sleepLT_intervals);
              LT_ripples = ripples.timestamps(sleep_logical_LT,:);
              [numRipples_LT,rippleLength_LT] = getNumAndLength_Ripples(LT_ripples);
         % make histogram of ripple length      
              [count_LT,~] = hist(rippleLength_LT,bin_length);
              % divide the number of each ripple length by the total number
              % of ripples
               plot(count_LT ./numRipples_LT, 'Color',exp_colors(3,:));
               rippleDistribution(3, :) = count_LT ./numRipples_LT;
               
               hold on;
               legend_info{3} = (['LT - ' sleep_order{LT_idx} ':' num2str(numRipples_LT)]);    
% Add graph specs
    xticks([0 10 20 30 40 50]);
    xticklabels({'0',num2str(bin_length(10)),num2str(bin_length(20)),num2str(bin_length(30)),...
                     num2str(bin_length(40)),num2str(bin_length(50))});
    xlabel('Ripple Length (s)');
    ylabel('Ripple ratio');
    legend(legend_info);
end