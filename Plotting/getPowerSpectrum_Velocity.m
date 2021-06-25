function [IRASA_Velocity] = getPowerSpectrum_Velocity(basePath, lfp_channel, Segment_Time, varargin)
% PURPOSE 
%          Makes power spectrum plot moving or not moving (original use for VR or no VR)
%          removed)
% INPUTS
%          Time          Struct: start and stop time of segment
%              .start
%              .stop
%          Lfp_channel   Numeric: idx of the channel to use
%          basePath      String : path with data in it
%          doLFPClean    Boolean: default is true, notch filter 60 hz over lfp
%          doSplitLFP    Boolean: default is true, splits lfp and calculates power spectra for each
%                                 segment and then averages, chunks data
%                                 and automatically makes movmean_win = 1
%          movmean_win   Numeric: default is 1, no smoothing window 
%          velocityThr   Numeric: Anything equal to or above is considered
%                                 running
% OUTPUTS
%          IRASA         Struct : Each power/freq time series for each segment
%          Plot comparing run vs no run (one plot with and one plot without
%                                        fractals)
% DEPENDENCIES
%          Buzcode       https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 05.11.2021
%% Input Parsers
p = inputParser;
addParameter(p,'doLFPClean',true,@islogical)
addParameter(p,'doSplitLFP',true,@islogical);
addParameter(p,'movmean_win',1,@isnumeric);
addParameter(p,'velocityThr',5,@isnumeric);
parse(p,varargin{:});
doLFPClean       = p.Results.doLFPClean;
doSplitLFP       = p.Results.doSplitLFP;
movmean_win      = p.Results.movmean_win;
velocityThr      = p.Results.velocityThr;
%% Get velocity and split into vectors
    basename = bz_BasenameFromBasepath(basePath);
        cd(basePath);
        load([basename '_analogin.mat']);
    % Get the analogin time for the segment time
        analogin_VR.pos = analogin.pos(Segment_Time.start*30000:Segment_Time.stop*30000);
        analogin_VR.blink = analogin.blink(Segment_Time.start*30000:Segment_Time.stop*30000);
        analogin_VR.ts = analogin.ts(Segment_Time.start*30000:Segment_Time.stop*30000);
        analogin_VR.sr = analogin.sr;
    % Get the running epochs
        [vel] = getVelocity(analogin_VR,'circDisk',236, 'doFigure', true);%236cm/unity lap
        [run] = getRunEpochs(basePath, vel, 'minRunSpeed', velocityThr);
        [no_run] = getNoRunEpochs(run);
%% Calculate power
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
% if doLFPClean is true then notch filter over 60 Hz
    if doLFPClean    
         lfp_run_clean = notchFilterMyLFP(lfp_Run);
         lfp_Run.data = lfp_run_clean';
         lfp_noRun_clean = notchFilterMyLFP(lfp_noRun);
         lfp_noRun.data = lfp_noRun_clean';
    end
    if ~doSplitLFP
        [powRun] = getPowerSpectrum(basePath, lfp_Run, 'doIRASA', false,'doPlot', false);
        [pownoRun] = getPowerSpectrum(basePath, lfp_noRun, 'doIRASA', false,'doPlot', false);
% if doSplitLFP is true, split in chunks and average power over all chunks
    elseif doSplitLFP
        minutes = 5; 
        timeMin = 1250*60*minutes;
        % Run
        [powRun] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_Run);
        % no Run
        [pownoRun] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp_noRun);
    end
%% Plot (with fractals)  
   color_all = linspecer(2);
   figure;
   % Plot the power spec for run epochs vs no run epochs
       plot(powRun.fma.spectrum, 'Color', color_all(1,:));
       hold on ;
       plot(pownoRun.fma.spectrum, 'Color', color_all(2,:));
       title('Velocity-Run vs no Run');
       xlabel('Frequency (Hz)');
       ylabel('Power');
       legend({'Run','No Run'});
%% Chunk lfp and Take out the fractals
    % take out fractals
    if ~doSplitLfp
          specRun = amri_sig_fractal(lfp_Run.data, lfp_Run.samplingRate,'detrend',1,'frange', [1 150]);
          specNoRun = amri_sig_fractal(lfp_noRun.data, lfp_noRun.samplingRate,'detrend',1,'frange', [1 150]);
    elseif doSplitLfp
        %make movmean 1 
        movmean_win = 1;
        
        specRun_freq =[];
        specRun_osci = [];
        specnoRun_freq =[];
        specnoRun_osci = [];
        
        endId = 0;
        sizeChunk = 2500;
        nChunks = floor(length(double(lfp_run.data))/sizeChunk);
        for iChunk = 1:nChunks
            startId = endId+1;
            endId = endId+sizeChunk;
            disp([startId, endId])
            
            selLFP_Run = double(lfp_Run.data(startId:endId));
            selLFP_noRun = double(lfp_noRun.data(startId:endId));
            
            specRun_temp = amri_sig_fractal(selLFP_Run,1250,'detrend',1,'frange',[1 150]);
            specNoRun_temp = amri_sig_fractal(selLFP_noRun,1250,'detrend',1,'frange',[1 150]);  
            
            specRun_freq = [specRun_freq;specRun_temp.freq'];
            specRun_osci = [specRun_osci;specRun_temp.osci'];
            specnoRun_freq = [specnoRun_freq;specNoRun_temp.freq'];
            specnoRun_osci = [specnoRun_osci;specNoRun_temp.osci'];
        end
            specRun.freq = specRun_freq;
            specRun.osci = specRun_osci;
            specNoRun.freq = specnoRun_freq;
            specNoRun.osci = specnoRun_osci;
    end
%% Plot (without fractals)
   color_all = linspecer(2);
   figure;
   % Plot the power spec for run epochs vs no run epochs
       plot(specRun.freq,movmean(specRun.osci,movmean_win), 'Color', color_all(1,:));
       hold on ;
       plot(specNoRun.freq,movmean(specNoRun.osci,movmean_win), 'Color', color_all(2,:));
       title('IRASA: Velocity-Run vs no Run');
       xlabel('Frequency (Hz)');
       ylabel('Power');
       totalRunTime = sum(run.epochs(:,2)-run.epochs(:,1));
       totalNoRunTime = sum(no_run(:,2)-no_run(:,1));
       legend({['Run: ' num2str(totalRunTime) '(s)'],['No Run: ' num2str(totalNoRunTime) '(s)']});
       %set(gca, 'YScale', 'log')
          axes('Position',[.6 .4 .3 .3])
          box on
          plot(specRun.freq,movmean(specRun.osci,movmean_win), 'Color', color_all(1,:));
          hold on ;
          plot(specNoRun.freq,movmean(specNoRun.osci,movmean_win), 'Color', color_all(2,:));
          xlim([0 15]);
%% Make output struct
    IRASA_Velocity.specRun = specRun;
    IRASA_Velocity.specNoRun = specNoRun;
end