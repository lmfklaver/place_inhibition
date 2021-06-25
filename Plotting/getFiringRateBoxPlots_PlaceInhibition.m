function [] = getFiringRateBoxPlots_PlaceInhibition(recDir,sleepQual)
% PURPOSE
%          This function is solely for the full day place inhibition experiments.
%          These experiments have a sequence of containing 4 sleep sessions, and 
%          3 experimental segments (linear track, virtual reality, and open
%          field)
%             
%          This function will create a series of 4 firing rate sleep box plots 
%          and 3 firing rate experimental box plots for each experimental
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
%          Two figures
%              - Box plots of firing rate during sleep segments
%              - Box plots of firing rate during experimental segments
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          Place Inhibition   https://github.com/rcbullins/place_inhibition
% TO DO
%          Axis is flipped right now, not sure how to change that. Also
%          seconds plot is not color coding correctly. If you need to make
%          a firing rate box plot just for one session use the function
%          getFR_BoxPlot_SingleSessoin_PlaceInhibition
% HISTORY
%          Reagan Bullins 06.21.2021
%% Set figure specs
% Set figures
    figure(1);
        firingRateFig = axes;
    figure(2);
        firingRateExp = axes;
% Set colors of sleep (4 sleep segments)
    warm_colors = hot(20); 
    color_all = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];
% Set colors of experiments
    cool_colors = cool(20);
    exp_colors = [cool_colors(3,:); cool_colors(7,:); cool_colors(11,:)];
% Set counter for the for loop (counts how many recordings in the directory
% have spikes - have been spike sorted)
    rec_num = 0;
% Set x tick marks, where box plots will be plotted (will need to expand if length(recDir) > 8)
     X1=[1,3,5,7,9,11,13,15];
     X2=[1.3 3.3 5.3 7.3 9.3 11.3 13.3 15.3];
     X3=[1.6 3.6 5.6 7.6 9.6 11.6 13.6 15.6];
     X4=[1.9 3.9 5.9 7.9 9.9 11.9 13.9 15.9];
%%  Find firing rate for each sleep and experimental segment, and boxplot it      
    for irec = 1:length(recDir)
        % load in the ripple file for this directory ( if does not exist -
        % create it)
             cd(recDir{irec});
             basePath = cd;
             basename = bz_BasenameFromBasepath(basePath);
             if ~isfile([basename '_TimeSegments.analysis.mat'])
                    [Time.Sleep1] = RealTime_Convert_RecordingTime(cd, 'SleepTime1');
                    [Time.Sleep2] = RealTime_Convert_RecordingTime(cd, 'SleepTime2');
                    [Time.Sleep3] = RealTime_Convert_RecordingTime(cd, 'SleepTime3');
                    [Time.Sleep4] = RealTime_Convert_RecordingTime(cd, 'SleepTime4');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.OF] = RealTime_Convert_RecordingTime(cd, 'OFTime');
                    [Time.LT] = RealTime_Convert_RecordingTime(cd, 'LTTime');
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
       % find sleep states that fall in sleep intervals (sleep times)
            if strcmp(sleepQual, 'NREM')
                [sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
                [sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
                [sleep3_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep3);
                [sleep4_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep4);
            elseif strcmp(sleepQual, 'REM')
                [sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
                [sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
                [sleep3_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep3);
                [sleep4_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep4);
            elseif strcmp(sleepQual, 'AllSleep')
                [NREM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep1);
                [NREM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep2);
                [NREM_sleep3_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep3);
                [NREM_sleep4_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.NREMstate, Time.Sleep4);
                [REM_sleep1_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep1);
                [REM_sleep2_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep2);
                [REM_sleep3_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep3);
                [REM_sleep4_intervals] = getIntervals_InBiggerIntervals(SleepState.ints.REMstate, Time.Sleep4);
                sleep1_intervals = [NREM_sleep1_intervals;REM_sleep1_intervals];
                sleep2_intervals = [NREM_sleep2_intervals;REM_sleep2_intervals];
                sleep3_intervals = [NREM_sleep3_intervals;REM_sleep3_intervals];
                sleep4_intervals = [NREM_sleep4_intervals;REM_sleep4_intervals];
            end
       % total time of each sleep interval
             SleepTotalTime.S1 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
             SleepTotalTime.S2 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
             SleepTotalTime.S3 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
             SleepTotalTime.S4 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
       % find how many spikes there are in each segment;
             sleep_FR_mat = zeros(length(spikes.times),4);
             exp_FR_mat = zeros(length(spikes.times),3);
             % for each cell, find the spike times within each sleep
             % interval and within each task interval
             for icell = 1:length(spikes.times)
                    [sleep_FR_mat(icell,1)] = getFiringRate(sleep1_intervals, spikes.times{icell});
                    [sleep_FR_mat(icell,2)] = getFiringRate(sleep2_intervals, spikes.times{icell});
                    [sleep_FR_mat(icell,3)] = getFiringRate(sleep3_intervals, spikes.times{icell});
                    [sleep_FR_mat(icell,4)] = getFiringRate(sleep4_intervals, spikes.times{icell});
                    [exp_FR_mat(icell,1)] = getFiringRate([Time.VR.start Time.VR.stop],spikes.times{icell});
                    [exp_FR_mat(icell,2)] = getFiringRate([Time.OF.start Time.OF.stop],spikes.times{icell});
                    [exp_FR_mat(icell,3)] = getFiringRate([Time.LT.start Time.LT.stop],spikes.times{icell});
             end
%% Plotting
       % boxplot firing rate (each box a different sleep session, each
       % point in a box plot is a cell)
%             boxplot(firingRateFig, sleep_FR_mat(:,1),'positions',X1(irec),'labels',X1(irec),'colors',color_all(1,:),'widths',0.25);
%             hold(firingRateFig, 'on');
%             boxplot(firingRateFig,sleep_FR_mat(:,2),'positions',X2(irec),'labels',X2(irec),'colors',color_all(2,:),'widths',0.25);
%             boxplot(firingRateFig,sleep_FR_mat(:,3),'positions',X3(irec),'labels',X3(irec),'colors',color_all(3,:),'widths',0.25);
%             boxplot(firingRateFig,sleep_FR_mat(:,4),'positions',X4 (irec),'labels',X4(irec),'colors',color_all(4,:),'widths',0.25);
%             title(firingRateFig,'Firing Rate For Sleep Sessions');
%             xticks(firingRateFig,X1(1:length(recDir)));
%             ylabel(firingRateFig, 'Firing Rate (spikes/s)');
%             sleep_labels = {'Sleep 1','Sleep 2','Sleep 3','Sleep 4'};
%             ylim([0 20]);
%             legend(flip(firingRateFig), flip(sleep_labels), 'Location', 'NorthWest');
                
                    boxplot(firingRateFig, sleep_FR_mat, [X1(irec) X2(irec) X3(irec) X4(irec)]);
                    hold(firingRateFig, 'on');
                    h = findobj(gca,'Tag','Box');
                    for j=1:length(h)
                        patch(get(h(j),'XData'),get(h(j),'YData'),color_all(j,:),'FaceAlpha',.5);
                    end
                    legend(firingRateFig,'Sleep 1','Sleep 2','Sleep 3','Sleep 4');
                    set(gca,'xticklabel',[]);
                    
                    boxplot(firingRateExp, exp_FR_mat, [X1(irec) X2(irec) X3(irec)]);
                    hold(firingRateExp, 'on');
                    h2 = findobj(gca,'Tag','Box');
                    for j=1:length(h2)
                        patch(get(h2(j),'XData'),get(h2(j),'YData'),color_all(j,:),'FaceAlpha',.5);
                    end
                    legend(firingRateExp,'VR','OF','LT');
                    set(gca,'xticklabel',[]);

%             boxplot(firingRateExp, exp_FR_mat, X1);
%             hold(firingRateExp, 'on');
%             title(firingRateExp, 'Firing Rate For Experimental Sessions');
%             xticks(firingRateExp, X1(1:length(recDir)));
%             ylabel(firingRateExp, 'Firing Rate (spikes/s)');
%             exp_labels = {'VR','LT','OF'};
%             legend(flip(firingRateExp), flip(exp_labels), 'Location', 'NorthWest');
%             ylim([0 20]);
    end
    
     title(firingRateFig,['Firing Rate For Sleep Sessions (n=' num2str(length(recDir)) ')']);
     title(firingRateExp,['Firing Rate For Experimental Sessions (n=' num2str(length(recDir)) ')']);
end