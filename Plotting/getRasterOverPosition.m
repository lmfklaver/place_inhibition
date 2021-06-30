function [] = getRasterOverPosition(spkEpVoltage, trials, varargin)
% PURPOSE
%          Make a raster plot of all the cells over position.
% INPUTS
%          spkEpVoltage     Array  : position of wheel during all spikes
%          trials           Matirx : start and stop times for each trial
%          length_cm_track  Numeric: How long track is in cm (default 236)
% OUTPUT
%          Raster plot (yxis is trials, x axis is position, and color is
%                       for cell idx)
% HISTORY
%          Reagan Bullins 05.04.2021
%% Input Parsers
p = inputParser;
addParameter(p,'length_cm_track',236,@isnumeric);

parse(p,varargin{:});
length_cm_track = p.Results.length_cm_track;
%%
% Make a color matrix, one color for each cell
    coloridx = linspecer(length(spkEpVoltage));
    jitter_amount = 1/length(spkEpVoltage);
%for every trial, plot every cells spikes on one row in a different
%color 
    abs_min = 1;
    abs_max = 1;
    for itrial = 1:length(trials)
       for icell = 1:length(spkEpVoltage)
    %            spikes_during_trial = find(spikes.times{icell} > trials(itrial,1) & spikes.times{icell} > trials(itrial,2));
               plot(spkEpVoltage{icell}.trial{itrial}, (itrial+(jitter_amount*(icell-1)))*ones(length(spkEpVoltage{icell}.trial{itrial})),'Color',coloridx(icell,:));
               hold on;
               % Find the absolute min and max voltage (this will help us
               % plot our raster and label our position tick marks right)
               relative_min = min(spkEpVoltage{icell}.trial{itrial});
               relative_max = max(spkEpVoltage{icell}.trial{itrial});
               if relative_min < abs_min
                   abs_min = relative_min;
               end
               if relative_max > abs_max
                   abs_max = relative_max;
               end

       end
    end
   
   diff_volt = abs_max-abs_min;
   ticks2place = diff_volt/5;
   volt2cm = length_cm_track/5;
   xticks([abs_min abs_min+ticks2place abs_min+(2*ticks2place) abs_min+(3*ticks2place)  abs_min+(4*ticks2place) abs_max]);
   xticklabels({'0',num2str(round(volt2cm)),num2str(round(volt2cm*2)),num2str(round(volt2cm*3)),num2str(round(volt2cm*4)),num2str(round(length_cm_track))});
   xlabel('Position');
   ylabel('Trials');
end
        