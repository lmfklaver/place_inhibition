function [rippleDistribution] = getRippleDurationDistribution_SpecificExperiment(Time, ripples, varargin)
% PURPOSE
%          Make a ripple duration distribution (histogram) for a specifc
%          Experiment.
%
% INPUTS
%          Time                  Struct: Struct with other structs for stop and start times of segment
%              .Sleep1.start
%              .Sleep1.stop
%              ...n sleeps
%          ripples               Struct: ripples.timestamps, start and stop of ripples
%              .timestamps
%
% OUTPUT
%          rippleDistribution    Matrix: (# exp segments X length(bin_length)) 
%                                        Distribution of ripple lengths
%          Distribution of ripples per duration length (y = ripple ratio
%         (count divided by all ripples), x = ripple duration, color = sleep
%          session)
% DEPENDENCIES
%          Buzcode               https://github.com/buzsakilab/buzcode
%          Place Inhibition      https://github.com/rcbullins/place_inhibition
% HISTORY
%          Reagan Bullins 06.23.2021
%% Input Parsers
p = inputParser;
addParameter(p,'bin_length',(0:.006:.3),@isvector);
parse(p,varargin{:});
bin_length       = p.Results.bin_length;

%% 
% Make sleep colors (warm colors, as in other functions in Place
% Inhibition)
    cool_colors =cool(20);
    exp_colors = [cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);cool_colors(12,:)];
% Want to plot for how many sleep segments there are
    stringFields = fieldnames(Time);
    Index_Exp = find(~contains(stringFields,'Sleep'));
    figure;
    rippleDistribution = zeros(length(Index_Exp),length(bin_length));
% For each sleep, find the numer of ripples and the length of each ripple
    for iexp = 1:length(Index_Exp)
         % find all specific sates into each sleep segment
              Time_StartStop = Time.(stringFields{Index_Exp(iexp)});
         % find how many ripples happen in each segment
              [sleep_logical, ~, ~] = InIntervals(ripples.timestamps, [Time_StartStop.start Time_StartStop.stop]);
              S_ripples = ripples.timestamps(sleep_logical,:);
              [numRipples,rippleLength] = getNumAndLength_Ripples(S_ripples);
         % make histogram of ripple length      
              [count,~] = hist(rippleLength,bin_length);
              % divide the number of each ripple length by the total number
              % of ripples
               plot(count ./numRipples, 'Color',exp_colors(iexp,:));
               rippleDistribution(iexp,:) = count ./numRipples;
               hold on;
               legend_info{iexp} = ([stringFields{Index_Exp(iexp)} ':' num2str(numRipples)]);
    end
% Add graph specs
 
    xlabel('Ripple Length (s)');
    ylabel('Ripple ratio');
    legend(legend_info);
        