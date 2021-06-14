function [IRASA] = getPowerSpectrum_SleepState(basePath, lfp_channel, Time, SleepState, varargin)

% Purpose: Makes power spectrum plots comparing sleep sessions in one plot
% and VR vs OF vs LT in another (also makes these plots with fractals
% removed)

% Inputs:  - Start and Stop struct for 2 sleep sessions, and VR and No VR
%          - Lfp_channel idx you want to use
%          - basePath: path with data in it
%          - doLFPClean: default is true, notch filter 60 hz over lfp
%          - doSplitLFP: default is true, splits lfp and calculates power spectra for each
%          segment and then averages
%          - movmean_win: default is 1000, smoothing window 

% Outputs: - IRASA struct: each power/freq time series for each segment
%          - Plot comparing sleep segments (with and without fractals)
%          - Plot comparing exper segments (with and without fractals)
%          - 3 Plots comparing each experimental segment with the previous
%          sleep segment
%          - Comprehensive plot with all segments

% Reagan: 2021.05.04

%%
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical);
addParameter(p,'movmean_win',100,@isnumeric);
addParameter(p,'max_ylim',1000,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
movmean_win     = p.Results.movmean_win;
max_ylim          = p.Results.max_ylim;

%%

% Set colors now, to be used for all graphs
    warm_colors = hot(20); %3,7,10,12 Sleep1
    cool_colors = cool(20);%3, 7, 11, 18  Sleep 2
    color_all = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:)]

% get lfp of each section independently (sperate wake, REM, NREM by which
% sleep they were in)
          [WAKE_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.WAKEstate, Time.Sleep1);
          [WAKE_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.WAKEstate, Time.Sleep2);
          [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
          [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
          [REM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
          [REM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
         
                                               
          cd(basePath);    
%% Get LFP for intervals
          lfp_S1_Wake = bz_GetLFP(lfp_channel, 'intervals', WAKE_sleep1_intervals);
          lfp_S2_Wake = bz_GetLFP(lfp_channel, 'intervals', WAKE_sleep2_intervals);
          lfp_S1_NREM = bz_GetLFP(lfp_channel, 'intervals', NREM_sleep1_intervals);
          lfp_S2_NREM = bz_GetLFP(lfp_channel, 'intervals', NREM_sleep2_intervals);
          lfp_S1_REM = bz_GetLFP(lfp_channel, 'intervals', REM_sleep1_intervals);
          lfp_S2_REM = bz_GetLFP(lfp_channel, 'intervals', REM_sleep2_intervals);
          
          if doLFPClean
               lfp_S1_Wake_clean = notchFilterMyLFP(lfp_S1_Wake);
               lfp_S1_Wake.data = lfp_S1_Wake_clean';
               lfp_S2_Wake_clean = notchFilterMyLFP(lfp_S2_Wake);
               lfp_S2_Wake.data = lfp_S2_Wake_clean';
               lfp_S1_NREM_clean = notchFilterMyLFP(lfp_S1_NREM);
               lfp_S1_NREM.data = lfp_S1_NREM_clean';
               lfp_S2_NREM_clean = notchFilterMyLFP(lfp_S2_NREM);
               lfp_S2_NREM.data = lfp_S2_NREM_clean';
               lfp_S1_REM_clean = notchFilterMyLFP(lfp_S1_REM);
               lfp_S1_REM.data = lfp_S1_REM_clean';
               lfp_S2_REM_clean = notchFilterMyLFP(lfp_S2_REM);
               lfp_S2_REM.data = lfp_S2_REM_clean';
          end
 %% average over chunks of time that vary in length to get lfp and power
        % Sleep 1 : Wake
              [lfp_S1_Wake_avg, powS1_wake] = makePowersperc_Avg_MixedIntervalSizes(basePath,WAKE_sleep1_intervals,lfp_S1_Wake);
         % Sleep 2 : Wake
              [lfp_S2_Wake_avg, powS2_wake] = makePowersperc_Avg_MixedIntervalSizes(basePath,WAKE_sleep2_intervals,lfp_S2_Wake);
         % Sleep 1: NREM
              [lfp_S1_NREM_avg, powS1_NREM] = makePowersperc_Avg_MixedIntervalSizes(basePath,NREM_sleep1_intervals,lfp_S1_NREM);
         % Sleep 2: NREM
              [lfp_S2_NREM_avg, powS2_NREM] = makePowersperc_Avg_MixedIntervalSizes(basePath,NREM_sleep2_intervals,lfp_S2_NREM);
         % Sleep 1: REM
              [lfp_S1_REM_avg, powS1_REM] = makePowersperc_Avg_MixedIntervalSizes(basePath,REM_sleep1_intervals,lfp_S1_REM);
         % Sleep 2: REM
              [lfp_S2_REM_avg, powS2_REM] = makePowersperc_Avg_MixedIntervalSizes(basePath,REM_sleep2_intervals,lfp_S2_REM);      
          %%
      % Compare Sleep 1 States
          figure;
          plot(powS1_wake.fma.spectrum, 'Color', color_all(1,:));
          hold on 
          plot(powS1_NREM.fma.spectrum, 'Color', color_all(2,:));
          plot(powS1_REM.fma.spectrum, 'Color', color_all(3,:));
          legend({'Wake','NREM','REM'});
          title('Powerspectrum for Sleep 1 States');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 100]);
          ylim([0 max_ylim]);
      % Compare Sleep 2 States
          figure;
          plot(powS2_wake.fma.spectrum, 'Color', color_all(4,:));
          hold on 
          plot(powS2_NREM.fma.spectrum, 'Color', color_all(5,:));
          plot(powS2_REM.fma.spectrum, 'Color', color_all(6,:));
          legend({'Wake','NREM','REM'});
          title('Powerspectrum for Sleep 2 States');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 100]);
          ylim([0 max_ylim]);  
      % Compare All states together
          figure;
          plot(powS1_wake.fma.spectrum, 'Color', color_all(1,:));
          hold on 
          plot(powS2_wake.fma.spectrum, 'Color', color_all(4,:));
          plot(powS1_NREM.fma.spectrum, 'Color', color_all(2,:));
          plot(powS2_NREM.fma.spectrum, 'Color', color_all(5,:));
          plot(powS1_REM.fma.spectrum, 'Color', color_all(3,:));
          plot(powS2_REM.fma.spectrum, 'Color', color_all(6,:));
          legend({'Wake S1','Wake S2','NREM S1','NREM S2','REM S1','REM S2'});
          title('Powerspectrum for all sleep states');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 100]);
          ylim([0 max_ylim]);
    % take out fractals
         % define sampling rate
            % see if there are more than one iterations
            if length(size(lfp_S1_Wake.samplingRate)) > 1
                lfp_sampRate = lfp_S1_Wake.samplingRate;
            elseif length(size(lfp_S1_Wake.samplingRate)) == 1
                lfp_sampRate = lfp_S1_Wake.samplingRate;
            end
         specS1_wake = amri_sig_fractal(lfp_S1_Wake_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
         specS2_wake = amri_sig_fractal(lfp_S2_Wake_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
         specS1_NREM = amri_sig_fractal(lfp_S1_NREM_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
         specS2_NREM = amri_sig_fractal(lfp_S2_NREM_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
         specS1_REM = amri_sig_fractal(lfp_S1_REM_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
         specS2_REM = amri_sig_fractal(lfp_S2_REM_avg,lfp_sampRate,'detrend',1,'frange', [1 150]);
   % Compare sleep 1 states (without fractals)
         figure;
         plot(specS1_wake.freq,movmean(specS1_wake.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specS1_NREM.freq,movmean(specS1_NREM.osci,movmean_win), 'Color', color_all(2,:));
         plot(specS1_REM.freq,movmean(specS1_REM.osci,movmean_win), 'Color', color_all(3,:));
         title('Powerspectrum for Sleep 1 States:No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'Wake','NREM','REM'});
         xlim([0 50]);
          ylim([0 max_ylim]);
   % Compare sleep 2 states (without fractals)
         figure;
         plot(specS2_wake.freq,movmean(specS2_wake.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specS2_NREM.freq,movmean(specS2_NREM.osci,movmean_win), 'Color', color_all(2,:));
         plot(specS2_REM.freq,movmean(specS2_REM.osci,movmean_win), 'Color', color_all(3,:));
         title('Powerspectrum for Sleep 2 States:No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'Wake','NREM','REM'});
         xlim([0 50]);
          ylim([0 max_ylim]);
   % Compare all sleep states (without fractals)
         % Compare sleep 2 states (without fractals)
         figure;
         plot(specS1_wake.freq,movmean(specS1_wake.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specS2_wake.freq,movmean(specS2_wake.osci,movmean_win), 'Color', color_all(4,:));
         plot(specS1_NREM.freq,movmean(specS1_NREM.osci,movmean_win), 'Color', color_all(2,:));
         plot(specS2_NREM.freq,movmean(specS2_NREM.osci,movmean_win), 'Color', color_all(5,:));
         plot(specS1_REM.freq,movmean(specS1_REM.osci,movmean_win), 'Color', color_all(3,:));
         plot(specS2_REM.freq,movmean(specS2_REM.osci,movmean_win), 'Color', color_all(6,:));
         title('Powerspectrum for All Sleep States:No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'Wake S1','Wake S2','NREM S1','NREM S2','REM S1','REM S2'});
         xlim([0 50]);
         ylim([0 max_ylim]);
    %% struct to output
        
      % IRASA
         IRASA.specS1_wake = specS1_wake;
         IRASA.specS2_wake = specS2_wake;
         IRASA.specS1_NREM = specS1_NREM;
         IRASA.specS2_NREM = specS2_NREM;
         IRASA.specS1_REM = specS1_REM;
         IRASA.specS2_REM = specS2_REM;
end