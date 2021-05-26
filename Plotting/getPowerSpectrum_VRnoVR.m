function [IRASA] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Sleep1_Time, Sleep2_Time, VR_Time, noVR_Time, varargin)

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
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1000,@isnumeric);
addParameter(p,'max_ylim',5,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win     = p.Results.movmean_win;
max_ylim          = p.Results.max_ylim;

%%
warm_colors = hot(20); %3,7,10,12
cool_colors = cool(20);%3, 7, 11, 18
color_all = [warm_colors(3,:);warm_colors(7,:);cool_colors(3,:);cool_colors(7,:)]
      % get lfp of each section independently
          lfp_S1 = bz_GetLFP(lfp_channel, 'intervals',[Sleep1_Time.start Sleep1_Time.stop]);
          lfp_S1.data = lfp_S1.data*0.195;
          lfp_S2 = bz_GetLFP(lfp_channel, 'intervals',[Sleep2_Time.start Sleep2_Time.stop]);
          lfp_S2.data = lfp_S2.data*0.195;
          lfp_VR = bz_GetLFP(lfp_channel, 'intervals',[VR_Time.start VR_Time.stop]);
          lfp_VR.data = lfp_VR.data*0.195;
          lfp_noVR = bz_GetLFP(lfp_channel, 'intervals',[noVR_Time.start noVR_Time.stop]);
          lfp_noVR.data = lfp_noVR.data*0.195;
          
          if doLFPClean
               lfp_S1_clean = notchFilterMyLFP(lfp_S1);
               lfp_S1.data = lfp_S1_clean';
               lfp_S2_clean = notchFilterMyLFP(lfp_S2);
               lfp_S2.data = lfp_S2_clean';
               lfp_VR_clean = notchFilterMyLFP(lfp_VR);
               lfp_VR.data = lfp_VR_clean';
               lfp_noVR_clean = notchFilterMyLFP(lfp_noVR);
               lfp_noVR.data = lfp_noVR_clean';
          end
          if ~doSplitLFP
              [powS1] = getPowerSpectrum(basePath, lfp_S1, 'doIRASA', false,'doPlot', false); 
              [powS2] = getPowerSpectrum(basePath, lfp_S2, 'doIRASA', false,'doPlot', false); 
              [powVR] = getPowerSpectrum(basePath, lfp_VR, 'doIRASA', false,'doPlot', false);
              [pownoVR] = getPowerSpectrum(basePath, lfp_noVR, 'doIRASA', false,'doPlot', false);
          elseif doSplitLFP
                  minutes = 5; 
                  timeMin = 1250*60*minutes;
              for iseg = 1:length(1:timeMin:length(lfp_S1.timestamps))
                  [powS1_temp] = getPowerSpectrum(basePath, lfp_S1, 'doIRASA', false, 'doPlot', false); 
                  pow1_mat(iseg,:) = powS1_temp.fma.spectrum;
              end
                  powS1.fma.spectrum = mean(pow1_mat);
              for iseg = 1:length(1:timeMin:length(lfp_S2.timestamps))
                  [powS2_temp] = getPowerSpectrum(basePath, lfp_S2, 'doIRASA', false, 'doPlot', false); 
                  pow2_mat(iseg,:) = powS2_temp.fma.spectrum;
              end
                  powS2.fma.spectrum = mean(pow2_mat);
              for iseg = 1:length(1:timeMin:length(lfp_VR.timestamps))
                  [powVR_temp] = getPowerSpectrum(basePath, lfp_VR, 'doIRASA', false, 'doPlot', false); 
                  powVR_mat(iseg,:) = powVR_temp.fma.spectrum;
              end
                  powVR.fma.spectrum = mean(powVR_mat); 
              for iseg = 1:length(1:timeMin:length(lfp_noVR.timestamps))
                  [pownoVR_temp] = getPowerSpectrum(basePath, lfp_noVR, 'doIRASA', false, 'doPlot', false); 
                  pownoVR_mat(iseg,:) = pownoVR_temp.fma.spectrum;
              end
                  pownoVR.fma.spectrum = mean(pownoVR_mat);
          end
      % Compare Sleep sessions
          figure;
          plot(powS1.fma.spectrum, 'Color', color_all(1,:));
          hold on 
          plot(powS2.fma.spectrum, 'Color', color_all(2,:));
          legend({'Sleep1','Sleep2'});
          title('Powerspectrum for Sleep Sessions');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 100]);
          ylim([0 max_ylim]);
  
      % Compare VR,and no VR
          figure;
          plot(powVR.fma.spectrum, 'Color', color_all(3,:));
          hold on;
          plot(pownoVR.fma.spectrum, 'Color', color_all(4,:));
          legend({'VR','no VR'});
          title('Powerspectrum for each setup');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 100]);
          ylim([0 max_ylim]);
    % take out fractals
         specS1 = amri_sig_fractal(lfp_S1.data, lfp_S1.samplingRate,'detrend',1,'frange', [1 150]);
         specS2 = amri_sig_fractal(lfp_S2.data, lfp_S2.samplingRate,'detrend',1,'frange', [1 150]);
         specVR = amri_sig_fractal(lfp_VR.data, lfp_VR.samplingRate,'detrend',1,'frange', [1 150]);
         specnoVR = amri_sig_fractal(lfp_noVR.data, lfp_noVR.samplingRate,'detrend',1,'frange', [1 150]);
      % Compare sleep sessions (without fractals)
         figure;
         plot(specS1.freq,movmean(specS1.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specS2.freq,movmean(specS2.osci,movmean_win), 'Color', color_all(2,:));
         title('Powerspectrum for Sleep Sessions:No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'Sleep1','Sleep2'});
         xlim([0 50]);
          ylim([0 max_ylim]);
      % Compare VR, and no VR (without fractals)
         figure;
         plot(specVR.freq,movmean(specVR.osci,movmean_win), 'Color', color_all(3,:));
         hold on;
         plot(specnoVR.freq,movmean(specnoVR.osci,movmean_win), 'Color', color_all(4,:));
         title('Powerspectrum for each setup: No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'VR','no VR'});
            xlim([0 50]);
          ylim([0 max_ylim]);
         %% maybe make a function for this
      % Compare VR and no VR each individually with mean sleep
         IRASA_sleep_freq = mean([specS1.freq, specS2.freq],2);
         IRASA_sleep_osci = mean([specS1.osci, specS2.osci],2);
         figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specVR.freq, movmean(specVR.osci,movmean_win), 'Color',color_all(3,:));
         legend({'Sleep', 'VR'});
         title('IRASA: Avg Sleep vs VR');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         xlim([0 50]);
          ylim([0 max_ylim]);
             axes('Position',[.6 .4 .3 .3])
             box on
             plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci, movmean_win),'Color',color_all(1,:));
             hold on
             plot(specVR.freq, movmean(specVR.osci,movmean_win), 'Color',color_all(3,:));
             xlim([0 15]) 
             ylim([0 max_ylim]);
        figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specnoVR.freq, movmean(specnoVR.osci,movmean_win),'Color', color_all(4,:));
         legend({'Sleep','no VR'});
         title('IRASA: Avg Sleep vs no VR');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         xlim([0 50]);
         ylim([0 max_ylim]);
             axes('Position',[.6 .4 .3 .3])
             box on
             plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci, movmean_win),'Color',color_all(1,:));
             hold on
             plot(specnoVR.freq, movmean(specnoVR.osci,movmean_win), 'Color',color_all(4,:));
             xlim([0 15])
             ylim([0 max_ylim]);
        %% maybe also make a function for this
        %plot each experimental setup with the sleep directly before only
        max_pow(1) = max(movmean(specVR.osci,movmean_win));
        max_pow(2) = max(movmean(specS1.osci,movmean_win));
        max_pow(3) = max(movmean(specS2.osci,movmean_win));
        max_pow(4) = max(movmean(specnoVR.osci,movmean_win));
        max_ylim = max(max_pow)+2;
        
        %find which experiment happened first and compare it to sleep
        %session one
        figure;
        all_fig = axes;
        plot(all_fig, specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
        hold on;
        if (VR_Time.start < noVR_Time.start)
             plot(all_fig, specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(3,:));
             hold on
             plot(all_fig, specnoVR.freq,movmean(specnoVR.osci,movmean_win),'Color',color_all(4,:));
             exper_one = 'VR';
             exper_two = 'noVR';
        elseif (noVR_Time.start < VR_Time.start)
             plot(all_fig, specnoVR.freq,movmean(specnoVR.osci,movmean_win),'Color',color_all(4,:));
             hold on
             plot(all_fig, specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(3,:));
             exper_one = 'noVR';
             exper_two = 'VR';
        end
          plot(all_fig, specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(2,:));
          legend(all_fig,{'Pre Sleep',[exper_one],[exper_two],'Post Sleep'});
          xlabel(all_fig,'Frequency (Hz)');
          ylabel(all_fig,'Power (mV)');
          title(all_fig,'IRASA');
          xlim(all_fig,[0 50]);
          ylim(all_fig,[0 max_ylim]);
        
      % IRASA
         IRASA.specS1 = specS1;
         IRASA.specS2 = specS2;
         IRASA.specVR = specVR;
         IRASA.specnoVR = specnoVR;
end     