function [IRASA] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time, varargin)
% PURPOSE 
%          Makes power spectrum plots comparing sleep sessions in one plot
%          and VR vs OF vs LT in another (also makes these plots with fractals
%          removed)
% INPUTS
%          Time          Struct: .start and .stop time structs 
%              .Sleep1
%              .Sleep2
%              .Sleep3
%              .Sleep4
%              .VR
%              .LT
%              .OF
%          Lfp_channel   Numeric: idx of the channel to use
%          basePath      String : path with data in it
%          doLFPClean    Boolean: default is true, notch filter 60 hz over lfp
%          doSplitLFP    Boolean: default is true, chunks lfp and makes
%                                  movmean_win = 1 automatically (already smooths)
%          movmean_win   Numeric: default is 1, no smoothing window 
% OUTPUTS
%          IRASA         Struct : Each power/freq time series for each segment
%               .specS1 
%               .specS2 
%               .specS3
%               .specS4
%               .specVR 
%               .specOF
%               .specLT 
%          Plot comparing sleep segments (with and without fractals)
%          Plot comparing exper segments (with and without fractals)
%          3 Plots comparing each experimental segment with the previous
%          sleep segment
%          Comprehensive plot with all segments
% DEPENDENCIES
%          Buzcode       https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 05.04.2021

%% Input Parsers
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1,@isnumeric);
addParameter(p,'max_ylim',30, @isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win      = p.Results.movmean_win;
max_ylim          = p.Results.max_ylim;

%% Set colors for graphing - do not change 
% sleep colors are warm, experimental colors are cool
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3, 7, 11, 18
    color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
%% Get lfp of each section independently and calculate power
% Get lfp
    lfp_S1 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep1.start Time.Sleep1.stop]);
    lfp_S1.data = lfp_S1.data*0.195;
    lfp_S2 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep2.start Time.Sleep2.stop]);
    lfp_S2.data = lfp_S2.data*0.195;
    lfp_S3 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep3.start Time.Sleep3.stop]);
    lfp_S3.data = lfp_S3.data*0.195;
    lfp_S4 = bz_GetLFP(lfp_channel, 'intervals',[Time.Sleep4.start Time.Sleep4.stop]);
    lfp_S4.data = lfp_S4.data*0.195;
    lfp_VR = bz_GetLFP(lfp_channel, 'intervals',[Time.VR.start Time.VR.stop]);
    lfp_VR.data = lfp_VR.data*0.195;
    lfp_OF = bz_GetLFP(lfp_channel, 'intervals',[Time.OF.start Time.OF.stop]);
    lfp_OF.data = lfp_OF.data*0.195;
    lfp_LT = bz_GetLFP(lfp_channel, 'intervals',[Time.LT.start Time.LT.stop]);
    lfp_LT.data = lfp_LT.data*0.195;
% If doLFPClean is true, notch filter out 60 Hz from the lfp
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
% If doSplitLFP is false, calculate powerspectra normally, if true, split
% the lfp in chunks and average power over the chunks
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
         timeMin = lfp_S1.samplingRate*60*minutes;
      % Sleep 1
         [powS1] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S1);           
      % Sleep 2
         [powS2] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S2);
      % Sleep 3
         [powS3] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S3);
      % Sleep 4
         [powS4] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_S4);
      % VR
         [powVR] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_VR);
      % LT
         [powLT] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_LT);
      % OF
         [powOF] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_OF);
    end
% Compare Sleep sessions
% Make a figure comparing power for all four sleep segments
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
% Make a figure comparing power for VR, LT, and OF
          figure;
              plot(powVR.fma.spectrum, 'Color', color_all(2,:));
              hold on;
              plot(powOF.fma.spectrum, 'Color', color_all(3,:));
              plot(powLT.fma.spectrum, 'Color', color_all(4,:));
              legend({'VR','OF','LT'});
              title('Powerspectrum for each setup');
              xlabel('Frequency (Hz)');
              ylabel('Power (mV)');
              xlim([0 50]);
              ylim([0 max_ylim]);
%% Chunk lfp and Take out the fractals
    % take out fractals
    if ~doSplitLFP
         specS1 = amri_sig_fractal(lfp_S1.data, lfp_S1.samplingRate,'detrend',1,'frange', [1 150]);
         specS2 = amri_sig_fractal(lfp_S2.data, lfp_S2.samplingRate,'detrend',1,'frange', [1 150]);
         specS3 = amri_sig_fractal(lfp_S3.data, lfp_S3.samplingRate,'detrend',1,'frange', [1 150]);
         specS4 = amri_sig_fractal(lfp_S4.data, lfp_S4.samplingRate,'detrend',1,'frange', [1 150]);
         specVR = amri_sig_fractal(lfp_VR.data, lfp_VR.samplingRate,'detrend',1,'frange', [1 150]);
         specOF = amri_sig_fractal(lfp_OF.data, lfp_OF.samplingRate,'detrend',1,'frange', [1 150]);
         specLT = amri_sig_fractal(lfp_LT.data, lfp_LT.samplingRate,'detrend',1,'frange', [1 150]);
    elseif doSplitLFP
        %make movmean 1 
        movmean_win = 1;
        
        specS1_freq =[];
        specS1_osci = [];
        specS2_freq =[];
        specS2_osci = [];
        specS3_freq =[];
        specS3_osci = [];
        specS4_freq =[];
        specS4_osci = [];
        specVR_freq =[];
        specVR_osci = [];
        specLT_freq =[];
        specLT_osci = [];
        specOF_freq =[];
        specOF_osci = [];
        
        endId = 0;
        sizeChunk = 2500;
        nChunks = floor(length(double(lfp_S1.data))/sizeChunk);
        for iChunk = 1:10%nChunks
            startId = endId+1;
            endId = endId+sizeChunk;
            disp([startId, endId])
            
            selLFP_S1 = double(lfp_S1.data(startId:endId));
            selLFP_S2 = double(lfp_S2.data(startId:endId));
            selLFP_S3 = double(lfp_S3.data(startId:endId));
            selLFP_S4 = double(lfp_S4.data(startId:endId));
            selLFP_VR = double(lfp_VR.data(startId:endId));
            selLFP_LT = double(lfp_LT.data(startId:endId));
            selLFP_OF = double(lfp_OF.data(startId:endId));
            
            specS1_temp = amri_sig_fractal(selLFP_S1,1250,'detrend',1,'frange',[1 150]);
            specS2_temp = amri_sig_fractal(selLFP_S2,1250,'detrend',1,'frange',[1 150]);  
            specS3_temp = amri_sig_fractal(selLFP_S3,1250,'detrend',1,'frange',[1 150]);    
            specS4_temp = amri_sig_fractal(selLFP_S4,1250,'detrend',1,'frange',[1 150]);  
            specVR_temp = amri_sig_fractal(selLFP_VR,1250,'detrend',1,'frange',[1 150]);
            specLT_temp = amri_sig_fractal(selLFP_LT,1250,'detrend',1,'frange',[1 150]); 
            specOF_temp = amri_sig_fractal(selLFP_OF,1250,'detrend',1,'frange',[1 150]);
            
            specS1_freq = [specS1_freq;specS1_temp.freq'];
            specS1_osci = [specS1_osci;specS1_temp.osci'];
            specS2_freq = [specS2_freq;specS2_temp.freq'];
            specS2_osci = [specS2_osci;specS2_temp.osci'];
            specS3_freq = [specS3_freq;specS3_temp.freq'];
            specS3_osci = [specS3_osci;specS3_temp.osci'];
            specS4_freq = [specS4_freq;specS4_temp.freq'];
            specS4_osci = [specS4_osci;specS4_temp.osci'];
            specVR_freq = [specVR_freq;specVR_temp.freq'];
            specVR_osci = [specVR_osci;specVR_temp.osci'];
            specLT_freq = [specLT_freq;specLT_temp.freq'];
            specLT_osci = [specLT_osci;specLT_temp.osci'];
            specOF_freq = [specOF_freq;specOF_temp.freq'];
            specOF_osci = [specOF_osci;specOF_temp.osci'];
        end
            specS1.freq = mean(specS1_freq);
            specS1.osci = mean(specS1_osci);
            specS2.freq = mean(specS2_freq);
            specS2.osci = mean(specS2_osci);
            specS3.freq = mean(specS3_freq);
            specS3.osci = mean(specS3_osci);
            specS4.freq = mean(specS4_freq);
            specS4.osci = mean(specS4_osci);
            specVR.freq = mean(specVR_freq);
            specVR.osci = mean(specVR_osci);
            specLT.freq = mean(specLT_freq);
            specLT.osci = mean(specLT_osci);
            specOF.freq = mean(specOF_freq);
            specOF.osci = mean(specOF_osci);
    end

    
%% Plotting            
     
% Compare sleep sessions (without fractals)
% Make a figure comparing sleep sessions without fractals
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
% Make a figure comparing experimental segments without fractals
     figure;
         plot(specVR.freq,movmean(specVR.osci,movmean_win), 'Color', color_all(2,:));
         hold on;
         plot(specOF.freq,movmean(specOF.osci,movmean_win), 'Color', color_all(3,:));
         plot(specLT.freq,movmean(specLT.osci,movmean_win), 'Color', color_all(4,:));
         title('Powerspectrum for each setup: No fractals');
         xlabel('Frequency (Hz)');
         ylabel('Power (mV)');
         legend({'VR','LT','OF'});
         ylim([0 max_ylim]);
         xlim([0 50]);
%% Compare VR, LT, OF each individually with mean sleep
% Find the mean sleep frequency and oscillation 
     IRASA_sleep_freq = mean([specS1.freq, specS2.freq, specS3.freq, specS4.freq],2);
     IRASA_sleep_osci = mean([specS1.osci, specS2.osci, specS3.osci, specS4.osci],2);
% Make a figure comparing mean sleep to VR
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
% Make a figure comparing mean sleep to LT
     figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specLT.freq, movmean(specLT.osci,movmean_win),'Color', color_all(4,:));
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
             plot(specLT.freq, movmean(specLT.osci,movmean_win), 'Color',color_all(4,:));
             xlim([0 15]) 
% Make a figure comparing mean sleep to OF
     figure;
         plot(IRASA_sleep_freq,movmean(IRASA_sleep_osci,movmean_win),'Color',color_all(1,:));
         hold on;
         plot(specOF.freq, movmean(specOF.osci,movmean_win),'Color', color_all(3,:));
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
             plot(specOF.freq, movmean(specOF.osci,movmean_win), 'Color',color_all(3,:));
             xlim([0 15])
%% Make the output struct (power without fractals)
  % IRASA
     IRASA.specS1 = specS1;
     IRASA.specS2 = specS2;
     IRASA.specS3 = specS3;
     IRASA.specS4 = specS4;
     IRASA.specVR = specVR;
     IRASA.specOF = specOF;
     IRASA.specLT = specLT;
     
     
%% Plot each experimental setup with the sleep directly before only
     getIRASAPlot_PlaceInhibition(IRASA, Time, 'movmean_win', movmean_win);
end     