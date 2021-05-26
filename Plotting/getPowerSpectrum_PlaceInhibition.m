function [IRASA] = getPowerSpectum_PlaceInhibition(basePath, lfp_channel, Sleep1_Time, Sleep2_Time, Sleep3_Time, Sleep4_Time, VR_Time, OF_Time, LT_Time, varargin)

% Purpose: Makes power spectrum plots comparing sleep sessions in one plot
% and VR vs OF vs LT in another (also makes these plots with fractals
% removed)

% Inputs:  - Start and Stop struct for all 4 sleep sessions, and 3
% experimental sessions
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
addParameter(p,'max_ylim',30, @isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win      = p.Results.movmean_win;
max_ylim          = p.Results.max_ylim;

%%
warm_colors = hot(20); %3,7,10,12
cool_colors = cool(20);%3, 7, 11, 18
color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
      % get lfp of each section independently
          lfp_S1 = bz_GetLFP(lfp_channel, 'intervals',[Sleep1_Time.start Sleep1_Time.stop]);
          lfp_S1.data = lfp_S1.data*0.195;
          lfp_S2 = bz_GetLFP(lfp_channel, 'intervals',[Sleep2_Time.start Sleep2_Time.stop]);
          lfp_S2.data = lfp_S2.data*0.195;
          lfp_S3 = bz_GetLFP(lfp_channel, 'intervals',[Sleep3_Time.start Sleep3_Time.stop]);
          lfp_S3.data = lfp_S3.data*0.195;
          lfp_S4 = bz_GetLFP(lfp_channel, 'intervals',[Sleep4_Time.start Sleep4_Time.stop]);
          lfp_S4.data = lfp_S4.data*0.195;
          lfp_VR = bz_GetLFP(lfp_channel, 'intervals',[VR_Time.start VR_Time.stop]);
          lfp_VR.data = lfp_VR.data*0.195;
          lfp_OF = bz_GetLFP(lfp_channel, 'intervals',[OF_Time.start OF_Time.stop]);
          lfp_OF.data = lfp_OF.data*0.195;
          lfp_LT = bz_GetLFP(lfp_channel, 'intervals',[LT_Time.start LT_Time.stop]);
          lfp_LT.data = lfp_LT.data*0.195;
          
          if doLFPClean
               lfp_S1_clean = notchFilterMyLFP(lfp_S1);
               lfp_S1.data = lfp_S1_clean';
               lfp_S2_clean = notchFilterMyLFP(lfp_S2);
               lfp_S2.data = lfp_S2_clean';
               lfp_S3_clean = notchFilterMyLFP(lfp_S3);
               lfp_S3.data = lfp_S3_clean';
               lfp_S4_clean = notchFilterMyLFP(lfp_S4);
               lfp_S4.data = lfp_S4_clean';
               lfp_VR_clean = notchFilterMyLFP(lfp_VR);
               lfp_VR.data = lfp_VR_clean';
               lfp_OF_clean = notchFilterMyLFP(lfp_OF);
               lfp_OF.data = lfp_OF_clean';
               lfp_LT_clean = notchFilterMyLFP(lfp_LT);
               lfp_LT.data = lfp_LT_clean';
          end
          if ~doSplitLFP
              [powS1] = getPowerSpectrum(basePath, lfp_S1, 'doIRASA', false,'doPlot', false); 
              [powS2] = getPowerSpectrum(basePath, lfp_S2, 'doIRASA', false,'doPlot', false); 
              [powS3] = getPowerSpectrum(basePath, lfp_S3, 'doIRASA', false,'doPlot', false); 
              [powS4] = getPowerSpectrum(basePath, lfp_S4, 'doIRASA', false,'doPlot', false); 
              [powVR] = getPowerSpectrum(basePath, lfp_VR, 'doIRASA', false,'doPlot', false);
              [powOF] = getPowerSpectrum(basePath, lfp_OF, 'doIRASA', false,'doPlot', false);
              [powLT] = getPowerSpectrum(basePath, lfp_LT, 'doIRASA', false,'doPlot', false);
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
              for iseg = 1:length(1:timeMin:length(lfp_S3.timestamps))
                  [powS3_temp] = getPowerSpectrum(basePath, lfp_S3, 'doIRASA', false, 'doPlot', false); 
                  pow3_mat(iseg,:) = powS3_temp.fma.spectrum;
              end
                  powS3.fma.spectrum = mean(pow3_mat);
              for iseg = 1:length(1:timeMin:length(lfp_S4.timestamps))
                  [powS4_temp] = getPowerSpectrum(basePath, lfp_S4, 'doIRASA', false, 'doPlot', false); 
                  pow4_mat(iseg,:) = powS4_temp.fma.spectrum;
              end
                  powS4.fma.spectrum = mean(pow4_mat);
              for iseg = 1:length(1:timeMin:length(lfp_VR.timestamps))
                  [powVR_temp] = getPowerSpectrum(basePath, lfp_VR, 'doIRASA', false, 'doPlot', false); 
                  powVR_mat(iseg,:) = powVR_temp.fma.spectrum;
              end
                  powVR.fma.spectrum = mean(powVR_mat); 
              for iseg = 1:length(1:timeMin:length(lfp_OF.timestamps))
                  [powOF_temp] = getPowerSpectrum(basePath, lfp_OF, 'doIRASA', false, 'doPlot', false); 
                  powOF_mat(iseg,:) = powOF_temp.fma.spectrum;
              end
                  powOF.fma.spectrum = mean(powOF_mat);
              for iseg = 1:length(1:timeMin:length(lfp_LT.timestamps))
                  [powLT_temp] = getPowerSpectrum(basePath, lfp_LT, 'doIRASA', false, 'doPlot', false); 
                  powLT_mat(iseg,:) = powLT_temp.fma.spectrum;
              end
                  powLT.fma.spectrum = mean(powLT_mat);
          end
      % Compare Sleep sessions
          figure;
          plot(powS1.fma.spectrum, 'Color', color_all(1,:));
          hold on 
          plot(powS2.fma.spectrum, 'Color', color_all(5,:));
          plot(powS3.fma.spectrum, 'Color', color_all(6,:));
          plot(powS4.fma.spectrum, 'Color', color_all(7,:));
          legend({'Sleep1','Sleep2','Sleep3','Sleep4'});
          title('Powerspectrum for Sleep Sessions');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 50]);
          ylim([0 max_ylim]);
      % Compare VR, OF, and LT sessions
          figure;
          plot(powVR.fma.spectrum, 'Color', color_all(2,:));
          hold on;
          plot(powLT.fma.spectrum, 'Color', color_all(3,:));
          plot(powOF.fma.spectrum, 'Color', color_all(4,:));
          legend({'VR','LT','OF'});
          title('Powerspectrum for each setup');
          xlabel('Frequency (Hz)');
          ylabel('Power (mV)');
          xlim([0 50]);
          ylim([0 max_ylim]);
 
    % take out fractals
         specS1 = amri_sig_fractal(lfp_S1.data, lfp_S1.samplingRate,'detrend',1,'frange', [1 150]);
         specS2 = amri_sig_fractal(lfp_S2.data, lfp_S2.samplingRate,'detrend',1,'frange', [1 150]);
         specS3 = amri_sig_fractal(lfp_S3.data, lfp_S3.samplingRate,'detrend',1,'frange', [1 150]);
         specS4 = amri_sig_fractal(lfp_S4.data, lfp_S4.samplingRate,'detrend',1,'frange', [1 150]);
         specVR = amri_sig_fractal(lfp_VR.data, lfp_VR.samplingRate,'detrend',1,'frange', [1 150]);
         specOF = amri_sig_fractal(lfp_OF.data, lfp_OF.samplingRate,'detrend',1,'frange', [1 150]);
         specLT = amri_sig_fractal(lfp_LT.data, lfp_LT.samplingRate,'detrend',1,'frange', [1 150]);
      % Compare sleep sessions (without fractals)
         figure;
         plot(specS1.freq,movmean(specS1.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specS2.freq,movmean(specS2.osci,movmean_win), 'Color', color_all(5,:));
         plot(specS3.freq,movmean(specS3.osci,movmean_win), 'Color', color_all(6,:));
         plot(specS4.freq,movmean(specS4.osci,movmean_win), 'Color', color_all(7,:));
         title('Powerspectrum for Sleep Sessions:No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'Sleep1','Sleep2','Sleep3','Sleep4'});
         ylim([0 max_ylim]);
         xlim([0 50]);
      % Compare VR, OF, and LT sessions (without fractals)
         figure;
         plot(specVR.freq,movmean(specVR.osci,movmean_win), 'Color', color_all(2,:));
         hold on;
          plot(specLT.freq,movmean(specLT.osci,movmean_win), 'Color', color_all(3,:));
         plot(specOF.freq,movmean(specOF.osci,movmean_win), 'Color', color_all(4,:));
 
         title('Powerspectrum for each setup: No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'VR','LT','OF'});
         ylim([0 max_ylim]);
         xlim([0 50]);
         %% maybe make a function for this
      % Compare VR, LT, OF each individually with mean sleep
         IRASA_sleep_freq = mean([specS1.freq, specS2.freq, specS3.freq, specS4.freq],2);
         IRASA_sleep_osci = mean([specS1.osci, specS2.osci, specS3.osci, specS4.osci],2);
         figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specVR.freq, movmean(specVR.osci,movmean_win), 'Color',color_all(2,:));
         legend({'Sleep', 'VR'});
         title('IRASA: Avg Sleep vs VR');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         ylim([0 max_ylim]);
         xlim([0 50]);
             axes('Position',[.6 .4 .3 .3])
             box on
             plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci, movmean_win),'Color',color_all(1,:));
             hold on
             plot(specVR.freq, movmean(specVR.osci,movmean_win), 'Color',color_all(2,:));
             xlim([0 15]) 
         figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specLT.freq, movmean(specLT.osci,movmean_win),'Color', color_all(3,:));
         legend({'Sleep','LT'});
         title('IRASA: Avg Sleep vs LT');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         ylim([0 max_ylim]);
         xlim([0 50]);
             axes('Position',[.6 .4 .3 .3])
             box on
             plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci, movmean_win),'Color',color_all(1,:));
             hold on
             plot(specLT.freq, movmean(specLT.osci,movmean_win), 'Color',color_all(3,:));
             xlim([0 15]) 
        figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specOF.freq, movmean(specOF.osci,movmean_win),'Color', color_all(4,:));
         legend({'Sleep','OF'});
         title('IRASA: Avg Sleep vs OF');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         ylim([0 max_ylim]);
         xlim([0 50]);
             axes('Position',[.6 .4 .3 .3])
             box on
             plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci, movmean_win),'Color',color_all(1,:));
             hold on
             plot(specOF.freq, movmean(specOF.osci,movmean_win), 'Color',color_all(4,:));
             xlim([0 15])
        %% maybe also make a function for this
        %plot each experimental setup with the sleep directly before only
        max_pow(1) = max(movmean(specVR.osci,movmean_win));
        max_pow(2) = max(movmean(specLT.osci,movmean_win));
        max_pow(3) = max(movmean(specOF.osci,movmean_win));
        max_ylim = max(max_pow)+10;
        
        %find which experiment happened first and compare it to sleep
        %session one
        figure;
        all_fig = axes;
        plot(all_fig, specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
        hold on;
        if (VR_Time.start < OF_Time.start & VR_Time.start < LT_Time.start)
             figure;
             plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 1','VR'});
             title('IRASA 1:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specVR.freq(movmean(specVR.osci,movmean_win) == (max(movmean(specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_one = 'VR';
            elseif (OF_Time.start<VR_Time.start & OF_Time.start < LT_Time.start)
             figure;
             plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 1','OF'});
             title('IRASA 1:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specOF.freq(movmean(specOF.osci,movmean_win) == (max(movmean(specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             exper_one = 'OF';
        elseif (LT_Time.start < VR_Time.start & LT_Time.start< OF_Time.start)
             figure;
             plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 1','LT'});
             title('IRASA 1:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS1.freq,movmean(specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specLT.freq(movmean(specLT.osci,movmean_win) == (max(movmean(specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             exper_one = 'LT';
        end
        
        plot(all_fig, specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
        %find middle session and plot to sleep 2
        if (VR_Time.start < OF_Time.start & VR_Time.start > LT_Time.start || VR_Time.start > OF_Time.start & VR_Time.start < LT_Time.start)
             figure;
             plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 2','VR'});
             title('IRASA 2:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specVR.freq(movmean(specVR.osci,movmean_win) == (max(movmean(specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_two = 'VR';
        elseif (LT_Time.start < OF_Time.start & LT_Time.start > VR_Time.start || LT_Time.start > OF_Time.start & LT_Time.start < VR_Time.start)
             figure;
             plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 2','LT'});
             title('IRASA 2:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specLT.freq(movmean(specLT.osci,movmean_win) == (max(movmean(specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             exper_two = 'LT';
        elseif (OF_Time.start < LT_Time.start & OF_Time.start > VR_Time.start || OF_Time.start > LT_Time.start & OF_Time.start < VR_Time.start)
             figure;
             plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 2','OF'});
             title('IRASA 2:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS2.freq,movmean(specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specOF.freq(movmean(specOF.osci,movmean_win) == (max(movmean(specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             exper_two = 'OF';
        end
        plot(all_fig, specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
    %find last session and plot to sleep 3
        if (VR_Time.start > LT_Time.start & VR_Time.start > OF_Time.start)
             figure;
             plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 3','VR'});
             title('IRASA 3:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specVR.freq(movmean(specVR.osci,movmean_win) == (max(movmean(specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specVR.freq,movmean(specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_three = 'VR';
        elseif (LT_Time.start> VR_Time.start & LT_Time.start >OF_Time.start)
             figure;
             plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 3','LT'});
             title('IRASA 3:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specLT.freq(movmean(specLT.osci,movmean_win) == (max(movmean(specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specLT.freq,movmean(specLT.osci,movmean_win),'Color',color_all(3,:));
             exper_three = 'LT';
        elseif (OF_Time.start > VR_Time.start & OF_Time.start >LT_Time.start)
             figure;
             plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 3','OF'});
             title('IRASA 3:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(specS3.freq,movmean(specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(specOF.freq(movmean(specOF.osci,movmean_win) == (max(movmean(specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, specOF.freq,movmean(specOF.osci,movmean_win),'Color',color_all(4,:));
             exper_three = 'OF';
        end
          plot(all_fig, specS4.freq,movmean(specS4.osci,movmean_win),'Color',color_all(7,:));
          legend(all_fig,{'Sleep 1',[exper_one],'Sleep 2', [exper_two],'Sleep 3',[exper_three],'Sleep 4'});
          xlabel(all_fig,'Frequency (Hz)');
          ylabel(all_fig,'Power (mV)');
          title(all_fig,'IRASA');
          xlim(all_fig,[0 50]);
          ylim([0 max_ylim]);

        %%
        
      % IRASA
         IRASA.specS1 = specS1;
         IRASA.specS2 = specS2;
         IRASA.specS3 = specS3;
         IRASA.specS4 = specS4;
         IRASA.specVR = specVR;
         IRASA.specOF = specOF;
         IRASA.specLT = specLT;
end     