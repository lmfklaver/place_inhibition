function [IRASA] = getPowerSpectrum_VRnoVR(basePath, lfp_channel,Time, varargin)
% PURPOSE
%          Makes power spectrum plots comparing sleep sessions in one plot
%          and VR vs OF vs LT in another (also makes these plots with fractals
%          removed)
% INPUTS
%          Time             Struct : .start and .stop times for VR and No VR
%              .VR
%              .noVR
%          lfp_channel      Numeric: channel idx you want to use
%          basePath         String : path with data in it
%          doLFPClean       Boolean: default is true, notch filter 60 hz over lfp
%          doSplitLFP       Boolean: default is true, splits lfp and calculates power spectra for each
%                                    segment and then averages. also makes
%                                    movemean_win = 1
%          movmean_win      Numeric: default is 1, no smoothing window 
% OUTPUTS 
%          IRASA            Struct: each power/freq time series for each segment
%              .specS1 
%              .specS2
%              .specVR 
%              .specnoVR 
%          Plot comparing sleep segments (with and without fractals)
%          Plot comparing exper segments (with and without fractals)
%          3 Plots comparing each experimental segment with the previous
%          sleep segment
%          Comprehensive plot with all segments
% DEPENDENCIES
%          Buzcode       https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 05.04.2021

%%
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1,@isnumeric);
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
          lfp_S1 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep1.start Time.Sleep1.stop]);
          lfp_S1.data = lfp_S1.data*0.195;
          lfp_S2 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep2.start Time.Sleep2.stop]);
          lfp_S2.data = lfp_S2.data*0.195;
          lfp_VR = bz_GetLFP(lfp_channel, 'intervals',[Time.VR.start Time.VR.stop]);
          lfp_VR.data = lfp_VR.data*0.195;
          lfp_noVR = bz_GetLFP(lfp_channel, 'intervals',[Time.noVR.start Time.noVR.stop]);
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
              % Sleep 1
                 [powS1] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S1);
              % Sleep 2
                 [powS2] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S2);
              % VR
                 [powVR] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_VR);
              % no VR
                 [pownoVR] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_noVR);
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
%% Chunk lfp and Take out the fractals
    % take out fractals
    if ~doSplitLFP
         specS1 = amri_sig_fractal(lfp_S1.data, lfp_S1.samplingRate,'detrend',1,'frange', [1 150]);
         specS2 = amri_sig_fractal(lfp_S2.data, lfp_S2.samplingRate,'detrend',1,'frange', [1 150]);
         specVR = amri_sig_fractal(lfp_VR.data, lfp_VR.samplingRate,'detrend',1,'frange', [1 150]);
         specnoVR = amri_sig_fractal(lfp_noVR.data, lfp_noVR.samplingRate,'detrend',1,'frange', [1 150]);
    elseif doSplitLFP
        %make movmean 1 
        movmean_win = 1;
        
        specS1_freq =[];
        specS1_osci = [];
        specS2_freq =[];
        specS2_osci = [];
        specVR_freq =[];
        specVR_osci = [];
        specnoVR_freq =[];
        specnoVR_osci = [];

        
        endId = 0;
        sizeChunk = 2500;
        nChunks = floor(length(double(lfp_S1.data))/sizeChunk);
        for iChunk = 1:nChunks
            startId = endId+1;
            endId = endId+sizeChunk;
            disp([startId, endId])
            
            selLFP_S1 = double(lfp_S1.data(startId:endId));
            selLFP_S2 = double(lfp_S2.data(startId:endId));
            selLFP_VR = double(lfp_VR.data(startId:endId));
            selLFP_noVR = double(lfp_noVR.data(startId:endId));

            
            specS1_temp = amri_sig_fractal(selLFP_S1,1250,'detrend',1,'frange',[1 150]);
            specS2_temp = amri_sig_fractal(selLFP_S2,1250,'detrend',1,'frange',[1 150]);  
            specVR_temp = amri_sig_fractal(selLFP_VR,1250,'detrend',1,'frange',[1 150]);    
            specnoVR_temp = amri_sig_fractal(selLFP_noVR,1250,'detrend',1,'frange',[1 150]);  
        
            specS1_freq = [specS1_freq;specS1_temp.freq'];
            specS1_osci = [specS1_osci;specS1_temp.osci'];
            specS2_freq = [specS2_freq;specS2_temp.freq'];
            specS2_osci = [specS2_osci;specS2_temp.osci'];
            specVR_freq = [specS3_freq;specS3_temp.freq'];
            specVR_osci = [specS3_osci;specS3_temp.osci'];
            specnoVR_freq = [specS4_freq;specnoVR_temp.freq'];
            specnoVR_osci = [specS4_osci;specnoVR_temp.osci'];

        end
            specS1.freq = mean(specS1_freq);
            specS1.osci = mean(specS1_osci);
            specS2.freq = mean(specS2_freq);
            specS2.osci = mean(specS2_osci);
            specVR.freq = mean(specS3_freq);
            specVR.osci = mean(specS3_osci);
            specnoVR.freq = mean(specS4_freq);
            specnoVR.osci = mean(specS4_osci);
    end

%% Plotting
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
%% Make struct to save    
  % IRASA
     IRASA.specS1 = specS1;
     IRASA.specS2 = specS2;
     IRASA.specVR = specVR;
     IRASA.specnoVR = specnoVR;

%% Make figure with all segments plotted in order of occurence 
     getIRASAPlot_VRnoVR(IRASA,Time,'movmean_win', movmean_win);

end     