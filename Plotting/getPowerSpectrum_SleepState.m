function [IRASA] = getPowerSpectrum_SleepState(basePath, lfp_channel, Time, SleepState, varargin)
% PURPOSE 
%          Makes power spectrum plots comparing sleep stages. Will run over
%          however many sleep fields you have in the time struct. Does
%          average over lfp 
% INPUTS
%          Time          Struct: .start and .stop time structs 
%              .Sleep1
%              .Sleep2
%              ... for n sleeps

%          Lfp_channel   Numeric: idx of the channel to use
%          basePath      String : path with data in it
%          doLFPClean    Boolean: default is true, notch filter 60 hz over lfp
%          movmean_win   Numeric: default is 1, no smoothing window 
% OUTPUTS
%          IRASA         Struct : Each power/freq time series for each segment
%          For each sleep field (sleep segment) create a figure with two
%          plots. The first plot is the power spectra for each sleep stage
%          (REM, NREM, and Wake) and the second one is the same figure but without
%          fractals.
% DEPENDENCIES
%          Buzcode           https://github.com/buzsakilab/buzcode
%          Place Inhibition  https://github.com/rcbullins/place_inhibition
% HISTORY
%          Reagan Bullins 05.04.2021

%% Set Input Parsers 
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical);
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1,@isnumeric);
addParameter(p,'max_ylim',1000,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win     = p.Results.movmean_win;
max_ylim          = p.Results.max_ylim;

%% Set Graph Specs
% Set colors now, to be used for all graphs
    warm_colors = hot(20); %3,7,10,12 Sleep1
    cool_colors = cool(20);%3, 7, 11, 18  Sleep 2
    color_all = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:)];
%% Go through each sleep session and find the states for each 
    stringFields = fieldnames(Time);
    Index_Sleep = find(contains(stringFields,'Sleep'));
    
    for isleep = 1:length(Index_Sleep)
    % Get the intervals for each sleep stage within isleep
      [WAKE_sleep_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.WAKEstate, Time.(stringFields{Index_Sleep(isleep)}));
      [NREM_sleep_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.(stringFields{Index_Sleep(isleep)}));
      [REM_sleep_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.(stringFields{Index_Sleep(isleep)}));
                                   
      cd(basePath);    
    % Get LFP for intervals
      lfp_Wake = bz_GetLFP(lfp_channel, 'intervals', WAKE_sleep_intervals);
      lfp_NREM = bz_GetLFP(lfp_channel, 'intervals', NREM_sleep_intervals);
      lfp_REM = bz_GetLFP(lfp_channel, 'intervals', REM_sleep_intervals);
    % If doLFPClean is true, notch filter over 60 Hz  
      if doLFPClean
           lfp_Wake_clean = notchFilterMyLFP(lfp_Wake);
           lfp_Wake.data = lfp_Wake_clean';
           lfp_NREM_clean = notchFilterMyLFP(lfp_NREM);
           lfp_NREM.data = lfp_NREM_clean';
           lfp_REM_clean = notchFilterMyLFP(lfp_REM);
           lfp_REM.data = lfp_REM_clean';
      end
     % Average over chunks of time that vary in length to get lfp and power
        % Sleep: Wake
              [lfp_Wake_avg, pow_wake] = makePowersperc_Avg_MixedIntervalSizes(basePath,WAKE_sleep_intervals,lfp_Wake);
         % Sleep: NREM
              [lfp_NREM_avg, pow_NREM] = makePowersperc_Avg_MixedIntervalSizes(basePath,NREM_sleep_intervals,lfp_NREM);
         % Sleep: REM
              [lfp_REM_avg, pow_REM] = makePowersperc_Avg_MixedIntervalSizes(basePath,REM_sleep_intervals,lfp_REM);
    % Compare Sleep States: Plot power specs of sleep stages
          figure;
              subplot(1,2,1);
                  plot(pow_wake.fma.spectrum, 'Color', color_all(1,:));
                  hold on 
                  plot(pow_NREM.fma.spectrum, 'Color', color_all(2,:));
                  plot(pow_REM.fma.spectrum, 'Color', color_all(3,:));
                  legend({'Wake','NREM','REM'});
                  title(['Powerspectrum for Sleep ' num2str(Index_Sleep(isleep)) ' States']);
                  xlabel('Frequency (Hz)');
                  ylabel('Power (mV)');
                  xlim([0 100]);
                  ylim([0 max_ylim]);
    % Take out fractals
         % define sampling rate
            % see if there are more than one iterations
            if length(size(lfp_Wake.samplingRate)) > 1
                lfp_sampRate = lfp_Wake.samplingRate;
            elseif length(size(lfp_Wake.samplingRate)) == 1
                lfp_sampRate = lfp_Wake.samplingRate;
            end
%% Chunk lfp and Take out the fractals
    % take out fractals
    if ~doSplitLFP
         spec_wake = amri_sig_fractal(lfp_Wake,lfp_sampRate,'detrend',1,'frange', [1 150]);
         spec_NREM = amri_sig_fractal(lfp_NREM,lfp_sampRate,'detrend',1,'frange', [1 150]);
         spec_REM = amri_sig_fractal(lfp_REM,lfp_sampRate,'detrend',1,'frange', [1 150]);

    elseif doSplitLFP
        %make movmean 1 
        movmean_win = 1;
        [specWake_freq, specWake_osci] = chunkLFP_takeOutFractals(lfp_Wake);
        [specNREM_freq, specNREM_osci] = chunkLFP_takeOutFractals(lfp_NREM);
        [specREM_freq, specREM_osci] = chunkLFP_takeOutFractals(lfp_REM);
        spec_wake.freq = specWake_freq;
        spec_wake.osci = specWake_osci;
        spec_NREM.freq = specNREM_freq;
        spec_NREM.osci = specNREM_osci;
        spec_REM.freq = specREM_freq;
        spec_REM.osci = specREM_osci;
    end   
         
%% Plotting
   % Compare sleep states (without fractals): Plot power specs of sleep stages
         subplot(1,2,2);
             plot(spec_wake.freq,movmean(spec_wake.osci,movmean_win), 'Color', color_all(1,:));
             hold on ;
             plot(spec_NREM.freq,movmean(spec_NREM.osci,movmean_win), 'Color', color_all(2,:));
             plot(spec_REM.freq,movmean(spec_REM.osci,movmean_win), 'Color', color_all(3,:));
             title(['Powerspectrum for Sleep ' num2str(Index_Sleep(isleep)) ' States:No fractals']);
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             totalWakeTime = sum(WAKE_sleep_intervals(:,2)-WAKE_sleep_intervals(:,1));
             totalNREMTime = sum(NREM_sleep_intervals(:,2)-NREM_sleep_intervals(:,1));
             totalREMTime = sum(REM_sleep_intervals(:,2)-REM_sleep_intervals(:,1));
             legend({['Wake: ' num2str(totalWakeTime) '(s)'],['NREM: ' num2str(totalNREMTime) '(s)'],['REM: ' num2str(totalREMTime) '(s)']});
             xlim([0 50]);
             ylim([0 max_ylim]);
   % IRASA output struct
          IRASA.(['specS' num2str(Index_Sleep(isleep)) '_wake']) = spec_wake;
          IRASA.(['specS' num2str(Index_Sleep(isleep)) '_NREM']) = spec_NREM;
          IRASA.(['specS' num2str(Index_Sleep(isleep)) '_REM']) = spec_REM;
    end 
    
end