function [sleep_FR_mat, exp_FR_mat] = getFiringRateBoxPlots_VRnoVR(recDir,sleepQual)
% PURPOSE
%          This function is solely for the VR, no VR experimental setup.
%          These experiments have a sequence of either... 
%              Sleep 1 > VR > no VR > Sleep 2
%              Sleep 1 > no VR > VR > Sleep 2
%          This function will create a series of 2 firing rate sleep box plots 
%          and 2 firing rate experimental (VR and no VR) box plots for each experimental
%          day. 
%
% INPUTS
%          recDir      Cell Array: Each cell contains a string of an
%                                  experimental session pathway
%          sleepQual   String    : Specify what you qualify as sleep
%                                      - NREM
%                                      - REM
%                                      - AllSleep
% OUTPUTS
%          sleep_FR_mat Matrix: each column is for a different sleep
%                               session, each row is the FR of a cell
%          exp_FR_mat   Matrix: each column is for a different experimental
%                               task, each row is the FR of a cell
%          Two figures
%              - Box plots of firing rate during sleep segments
%              - Box plots of firing rate during experimental segments
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          Place Inhibition   https://github.com/rcbullins/place_inhibition
% TO DO
%          Does not perfectly plot, the colors do not plot right. See
%          function getFR_BoxPlot_SingleSession_VRnoVR to do one session at
%          a time. That function works great.
% HISTORY
%          Reagan Bullins 06.21.2021
%% Set figure specs
% Initiate figures to plot on in for loop
    figure(1);
        firingRateFig = axes;
    figure(2);
        firingRateExp = axes;
% Set colors of sleep segments 1 and 2
    warm_colors = hot(20); 
    color_sleep = [warm_colors(3,:);warm_colors(7,:)];
% Set colors of experimental segments, VR, LT, OF
    cool_colors = cool(20);
    exp_colors = [cool_colors(3,:); cool_colors(7,:); cool_colors(11,:)];
% Initate counter for how many recordings in directory have spikes 
    rec_num = 0;
% Initate x axis plotting (will need to expand if length(recDir) > 8)
     X1=[1,3,5,7,9,11,13,15];
     X2=[1.3 3.3 5.3 7.3 9.3 11.3 13.3 15.3];
     X3=[1.6 3.6 5.6 7.6 9.6 11.6 13.6 15.6];
     X4=[1.9 3.9 5.9 7.9 9.9 11.9 13.9 15.9];
%% Find firing rate for each sleep and experimental segment, and boxplot it      
    for irec = 1:length(recDir)
        % load in the ripple file for this directory ( if does not exist -
        % create it)
             cd(recDir{irec});
             basePath = cd;
             basename = bz_BasenameFromBasepath(basePath);
             if ~isfile([basename '_TimeSegments.analysis.mat'])
                    [Time.Sleep1] = RealTime_Convert_RecordingTime(cd, 'SleepTime1');
                    [Time.Sleep2] = RealTime_Convert_RecordingTime(cd, 'SleepTime2');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.noVR] = RealTime_Convert_RecordingTime(cd, 'VRNoTime');       
                    save([basename '_TimeSegments.analysis.mat'],'Time');
             end
             load([basename '_TimeSegments.analysis.mat']);
       % load in spiking info
             if ~isfile([basename '.spikes.cellinfo.mat'])
                     continue; %need to get spikes before doing this
             else
                 rec_num = rec_num +1;
             end
             load([basename '.spikes.cellinfo.mat']);
        % load in the sleep state mat (if does not exist - create it)
             if ~isfile([basename '_SleepState.analysis.mat'])
                 lfp_chans2check = [10 30 60]; %make sure channels are good ones
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
             end 
             load([basename '_SleepState.analysis.mat']);
       % find sleep state that fall in sleep intervals (sleep times)
            if strcmp(sleepQual, 'NREM')
                [sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
                [sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
            elseif strcmp(sleepQual, 'REM')
                [sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
                [sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
            elseif strcmp(sleepQual, 'AllSleep')
                [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
                [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
                [REM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
                [REM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
                sleep1_intervals = [NREM_sleep1_intervals;REM_sleep1_intervals];
                sleep2_intervals = [NREM_sleep2_intervals;REM_sleep2_intervals];
            end
          
       % total time of each sleep interval
             SleepTotalTime.S1 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
             SleepTotalTime.S2 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));

       % find how many spikes there are in each segment;
             sleep_FR_mat = zeros(length(spikes.times),4);
             exp_FR_mat = zeros(length(spikes.times),3);
             % for each cell, find the spike times within each sleep
             % interval and within each task interval
             for icell = 1:length(spikes.times)
                    [sleep_FR_mat(icell,1)] = getFiringRate(sleep1_intervals, spikes.times{icell});
                    [sleep_FR_mat(icell,2)] = getFiringRate(sleep2_intervals, spikes.times{icell});
                    [exp_FR_mat(icell,1)] = getFiringRate([Time.VR.start Time.VR.stop],spikes.times{icell});
                    [exp_FR_mat(icell,2)] = getFiringRate([Time.noVR.start Time.noVR.stop],spikes.times{icell});
                
             end
       % boxplot firing rate (each box a different sleep session, each
       % point in a box plot is a cell)
            boxplot(firingRateFig, sleep_FR_mat(:,1),'positions',X1(irec),'labels',X1(irec),'colors',color_sleep(1,:),'widths',0.25);
            hold(firingRateFig, 'on');
            boxplot(firingRateFig,sleep_FR_mat(:,2),'positions',X2(irec),'labels',X2(irec),'colors',color_sleep(2,:),'widths',0.25);
            title(firingRateFig,'Firing Rate For Sleep Sessions');
            xticks(firingRateFig,X1(1:length(recDir)));
            ylabel(firingRateFig, 'Firing Rate (spikes/s)');
            legend(firingRateFig, findall(gca,'Tag','Box'), {'Sleep 1','Sleep 2'});
            ylim([0 20]);
            
            boxplot(firingRateExp, exp_FR_mat(:,1),'positions',X1(irec),'labels',X1(irec),'colors',exp_colors(1,:),'widths',0.25);
            hold(firingRateExp, 'on');
            boxplot(firingRateExp, exp_FR_mat(:,2),'positions',X2(irec),'labels',X2(irec),'colors',exp_colors(2,:),'widths',0.25);
            title(firingRateExp, 'Firing Rate For Experimental Sessions');
            xticks(firingRateExp, X1(1:length(recDir)));
            ylabel(firingRateExp, 'Firing Rate (spikes/s)');
            hLegend = legend(firingRateExp,findall(gca,'Tag','Box'), {'VR','no VR'});
            ylim([0 20]);
    end
end