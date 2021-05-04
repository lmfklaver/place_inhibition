function [] = getPowerSpectum_PlaceInhibition(basePath, lfp_channel, Sleep1_Time, Sleep2_Time, Sleep3_Time, Sleep4_Time, VR_Time, OF_Time, LT_Time)

% Purpose: Makes power spectrum plots comparing sleep sessions in one plot
% and VR vs OF vs LT in another (also makes these plots with fractals
% removed)

% Inputs:  - Start and Stop struct for all 4 sleep sessions, and 3
% experimental sessions
%          - Lfp_channel idx you want to use
%          - basePath: path with data in it

% Outputs: - 4 power spectrum plots 

% Reagan: 2021.05.04

      % get lfp of each section independently
          lfp_S1 = bz_GetLFP(lfp_channel, 'intervals',[Sleep1_Time.start Sleep1_Time.stop]);
          lfp_S2 = bz_GetLFP(lfp_channel, 'intervals',[Sleep2_Time.start Sleep2_Time.stop]);
          lfp_S3 = bz_GetLFP(lfp_channel, 'intervals',[Sleep3_Time.start Sleep3_Time.stop]);
          lfp_S4 = bz_GetLFP(lfp_channel, 'intervals',[Sleep4_Time.start Sleep4_Time.stop]);
          lfp_VR = bz_GetLFP(lfp_channel, 'intervals',[VR_Time.start VR_Time.stop]);
          lfp_OF = bz_GetLFP(lfp_channel, 'intervals',[OF_Time.start OF_Time.stop]);
          lfp_LT = bz_GetLFP(lfp_channel, 'intervals',[LT_Time.start LT_Time.stop]);
          [powS1] = getPowerSpectrum(basePath, lfp_S1); 
          [powS2] = getPowerSpectrum(basePath, lfp_S2); 
          [powS3] = getPowerSpectrum(basePath, lfp_S3); 
          [powS4] = getPowerSpectrum(basePath, lfp_S4); 
          [powVR] = getPowerSpectrum(basePath, lfp_VR);
          [powOF] = getPowerSpectrum(basePath, lfp_OF);
          [powLT] = getPowerSpectrum(basePath, lfp_LT);
      % Compare Sleep sessions
          figure;
          color_sleep = linspecer(4);
          plot(powS1, 'Color', color_sleep(1));
          hold on 
          plot(powS2, 'Color', color_sleep(2));
          plot(powS3, 'Color', color_sleep(3));
          plot(powS4, 'Color', color_sleep(4));
          legend({'Sleep1','Sleep2','Sleep3','Sleep4'});
          title('Powerspectrum for Sleep Sessions');
          xlabel('Frequency');
          ylabel('Power');
      % Compare VR, OF, and LT sessions
          figure;
          color_exp = linspecer(3);
          plot(powVR, 'Color', color_exp(1));
          hold on;
          plot(powOF, 'Color', color_exp(2));
          plot(powLT, 'Color', color_exp(3));
          legend({'VR','OF','LT'});
          title('Powerspectrum for each setup');
          xlabel('Frequency');
          ylabel('Power');
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
         plot(specS1.freq,movmean(specS1.osci,10000), 'Color', color_sleep(1));
         hold on ;
         plot(specS2.freq,movmean(specS2.osci,10000), 'Color', color_sleep(2));
         plot(specS3.freq,movmean(specS3.osci,10000), 'Color', color_sleep(3));
         plot(specS4.freq,movmean(specS4.osci,10000), 'Color', color_sleep(4));
         title('Powerspectrum for Sleep Sessions:No fractals');
         xlabel('Frequency');
         ylabel('Power');
         legend({'Sleep1','Sleep2','Sleep3','Sleep4'});
      % Compare VR, OF, and LT sessions (without fractals)
         figure;
         plot(specVR.freq,movmean(specVR.osci,10000), 'Color', color_exp(1));
         hold on;
         plot(specOF.freq,movmean(specOF.osci,10000), 'Color', color_exp(2));
         plot(specLT.freq,movmean(specLT.osci,10000), 'Color', color_exp(3));
         title('Powerspectrum for each setup: No fractals');
         xlabel('Frequency');
         ylabel('Power');
         legend({'VR','OF','LT'});
end     