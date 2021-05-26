function [] = getRasterOverPosition(spikes, trials)

    % input: spikes struct
    %        trials (matrix of start and stop times for each trial)
    % output: raster plot (yxis is trials, x axis is position, and color is
    % for cell idx)
    figure
    coloridx = linspecer(length(spikes.times));
 
   %for every trial, plot every cells spikes on one row in a different
   %color (Lianne - ADD in or equal to???)
   for itrial = 1:length(trials)
       for icell = 1:length(spikes.times)
           spikes_during_trial = find(spikes.times{icell} > trials(itrial,1) & spikes.times{icell} > trials(itrial,2)); 
           plot(spikes_during_trial, icell*ones(length(spikes_during_trial)),'Color',coloridx(icell));
        hold on
       end
   end
   title('Cell activity over position')
   xlabel('Position')
   ylabel('Trials')
   
end
        