function [IRASA_Velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Segment_Time, varargin)
% Purpose: Makes power spectrum comparing velocity over and under a
% certain threshold. 

% Inputs:  - Start and Stop struct for all 4 sleep sessions, and 3
% experimental sessions
%          - Lfp_channel idx you want to use
%          - basePath: path with data in it
%          - doLFPClean: default is true, notch filter 60 hz over lfp
%          - doSplitLFP: default is true, splits lfp and calculates power spectra for each
%          segment and then averages
%          - movmean_win: default is 1000, smoothing window for movmean 
%          - velocityThr: velocity cm/s at which anything equal to or above
%          is considered running

% Outputs: - IRASA struct: each power/freq time series for each segment
%          - Plot comparing run vs no run

% Reagan: 2021.05.11
%% Inputs
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1000,@isnumeric);
addParameter(p,'velocityThr',5,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win      = p.Results.movmean_win;
velocityThr      = p.Results.velocityThr;
%% Get velocity and split into vectors
basename = bz_BasenameFromBasepath(basePath);
load([basename '_analogin.mat']);
    cd(basePath);
    load([basename '_analogin.mat']);
    analogin_VR.pos = analogin.pos(Segment_Time.start*30000:Segment_Time.stop*30000);
    analogin_VR.blink = analogin.blink(Segment_Time.start*30000:Segment_Time.stop*30000);
    analogin_VR.ts = analogin.ts(Segment_Time.start*30000:Segment_Time.stop*30000);
    analogin_VR.sr = analogin.sr;
[vel] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
[run] = getRunEpochs(basePath, vel);
[no_run] = getNoRunEpochs(run);
%%
 color_all = linspecer(2);
      % get total lfp
          lfp_all = bz_GetLFP(lfp_channel);
      % find the indexes lfp timestamps when the animal is running
          idx_run = InIntervals(lfp_all.timestamps, run.epochs);
          idx_noRun = InIntervals(lfp_all.timestamps,no_run);
      % make lfp struct - assign timestamps to only equal the lfp
      % timestamps that were during the running epochs
          lfp_Run.timestamps = lfp_all.timestamps(idx_run);
          lfp_Run.data = lfp_all.data(idx_run);
          lfp_Run.samplingRate = lfp_all.samplingRate;
          lfp_noRun.timestamps = lfp_all.timestamps(idx_noRun);
          lfp_noRun.data = lfp_all.data(idx_noRun);
          lfp_noRun.samplingRate = lfp_all.samplingRate;
          if doLFPClean    
               lfp_run_clean = notchFilterMyLFP(lfp_Run);
               lfp_Run.data = lfp_run_clean';
               lfp_noRun_clean = notchFilterMyLFP(lfp_noRun);
               lfp_noRun.data = lfp_noRun_clean';
          end
          if ~doSplitLFP
              [pow_Run] = getPowerSpectrum(basePath, lfp_Run, 'doIRASA', false,'doPlot', false);
              [pow_noRun] = getPowerSpectrum(basePath, lfp_noRun, 'doIRASA', false,'doPlot', false);
          elseif doSplitLFP
                  minutes = 5; 
                  timeMin = 1250*60*minutes;
              for iseg = 1:length(1:timeMin:length(lfp_Run.timestamps))
                  [powRun_temp] = getPowerSpectrum(basePath, lfp_Run, 'doIRASA', false, 'doPlot', false); 
                  powRun_mat(iseg,:) = powRun_temp.fma.spectrum;
              end
                  powRun.fma.spectrum = mean(powRun_mat);
              for iseg = 1:length(1:timeMin:length(lfp_noRun.timestamps))
                  [pownoRun_temp] = getPowerSpectrum(basePath, lfp_noRun, 'doIRASA', false, 'doPlot', false); 
                  pownoRun_mat(iseg,:) = pownoRun_temp.fma.spectrum;
              end
                  pownoRun.fma.spectrum = mean(pownoRun_mat);
          end
%% take out fractals
         specRun = amri_sig_fractal(lfp_Run.data, lfp_Run.samplingRate,'detrend',1,'frange', [1 150]);
         specNoRun = amri_sig_fractal(lfp_noRun.data, lfp_noRun.samplingRate,'detrend',1,'frange', [1 150]);
%% Plot 
         figure;
         plot(specRun.freq,movmean(specRun.osci,movmean_win), 'Color', color_all(1,:));
         hold on ;
         plot(specNoRun.freq,movmean(specNoRun.osci,movmean_win), 'Color', color_all(2,:));
         title('IRASA: Velocity-Run vs no Run');
         xlabel('Frequency (Hz)');
         ylabel('Power');
         legend({'Run','No Run'});
         %set(gca, 'YScale', 'log')
            axes('Position',[.6 .4 .3 .3])
            box on
            plot(specRun.freq,movmean(specRun.osci,movmean_win), 'Color', color_all(1,:));
            hold on ;
            plot(specNoRun.freq,movmean(specNoRun.osci,movmean_win), 'Color', color_all(2,:));
            xlim([15 20])
%% make output
         IRASA_Velocity.specRun = specRun;
         IRASA_Velocity.specNoRun = specNoRun;
end