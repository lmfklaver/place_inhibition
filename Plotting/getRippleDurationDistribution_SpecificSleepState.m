function [] = getRippleDurationDistribution_SpecificSleepState(specificSleepState, Time, ripples, varargin)
%%
% Purpose: Make a ripple duration distribution (histogram) for a specifc
% state of sleep (Wake, NREM, or REM). Seperate each of the sleep sessions.

% Input: Time struct with sleep start and stop times (Time.Sleep1.start...)
%        SleepState start and stop times
%        (SleepState.ints.NREMstate..REMstate...WAKEstate)

% Output: Distribution of ripples per duration length (y = ripple ratio
% (count divided by all ripples), x = ripple duration, color = sleep
% session)

% Reagan Bullins 6/12/21
%%
p = inputParser;
addParameter(p,'bin_length',(0:.006:.3),@isvector);
parse(p,varargin{:});
bin_length       = p.Results.bin_length;

%%
        % make colors
        warm_colors = hot(20);
        sleep_colors = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];
        %want to plot for how many sleep segments there are
        stringFields = fieldnames(Time);
        Index_Sleep = find(contains(stringFields,'Sleep'));
    for isleep = 1:length(Index_Sleep)
         % split NREM segments into each sleep segment
             %%% WORKING HERE %%%
             Time_StartStop = Time.(stringFields{Index_Sleep(isleep)});
              [sleep_intervals] = getIntervals_InBiggerIntervals(specificSleepState, Time_StartStop);
        
             % find how many ripples happen in each segment
                    [sleep_logical, ~, ~] = InIntervals(ripples.timestamps,  sleep_intervals);
                    S_ripples = ripples.timestamps(sleep_logical,:);
                    [numRipples,rippleLength] = getNumAndLength_Ripples(S_ripples);
               
        [count,edges] = hist(rippleLength,bin_length);
        plot(count ./numRipples, 'Color',sleep_colors(isleep,:));
        hold on;
        legend_info{isleep} = ([stringFields{Index_Sleep(isleep)} ':' num2str(numRipples)]);
    end
        xticks([0 10 20 30 40 50])
        xticklabels({'0',[num2str(bin_length(10))],[num2str(bin_length(20))],[num2str(bin_length(30))],[num2str(bin_length(40))],[num2str(bin_length(50))]});
        xlabel('Ripple Length (s)')
        ylabel('Ripple ratio');
        legend(legend_info);
        
end