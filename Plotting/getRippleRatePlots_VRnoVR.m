function [rippleRateMat,totalTimeMat, rippleRateExpTask] = getRippleRatePlots_VRnoVR(recDir, sleepQual)
% PURPOSE
%          This function is solely for the VR / no VR experiments.
%          These experiments have a sequence containing 2 sleep sessions, and 
%          2 experimental segments (VR and no VR)
%
%          This function will create a series of figures to show ripple
%          rate in the two sleep sessions. 
%
% INPUTS
%          recDir      Cell Array: Each cell contains a string of an
%                                  experimental session pathway
%          sleepQual   String    : Specify what you qualify as sleep
%                                      - NREM
%                                      - REM
%                                      - AllSleep
%
% OUTPUTS
%          rippleRateMat      Matrix   : (# recordings X # sleep sessions)
%          totalTimeMat       Matrix   : (# recordings X # sleep sessions)
%          rippleRateExpTask  Matrix   : (# recordings X # exp sessions)
%          Three figures
%              - Dot plots of ripple rate per experimental session
%              - Dot plots of length of time in sleep state per
%                experimental session
%              - Box plots of ripple rate and time spent in sleep state
%                over all sessions
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          Place Inhibition   https://github.com/rcbullins/place_inhibition
% TO DO
%         Currently, throughout the place inhibtion scrips warm colors are
%         sleep and cool colors are behaviors, however this function has colors for
%         experimental session days. For these colors I am using the sleep and exp
%         colors -- THIS could get confusing.
% HISTORY
%         Reagan Bullins 06.21.2021

%% Set figure specs
% Figure for ripple rate in for loop
    figure(1);
        rippleRateFig = axes;
% Figure for time spent in sleep state in for loop
    figure(2);
        timeStateFig = axes;
% Colors to plot experimental days by
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3,7,10,12
    color_all = [warm_colors(3,:);cool_colors(3,:);warm_colors(7,:);cool_colors(7,:);warm_colors(10,:);cool_colors(10,:);warm_colors(12,:);cool_colors(12,:)];

% Allocate for speed
    rippleRateMat = zeros(length(recDir),2);
    totalTimeMat = zeros(length(recDir),2);
    rippleRateExpTask = zeros(length(recDir),2);
%% For each recording, calculate the ripple rate and plot it on a figure   
    for irec = 1:length(recDir)
        % load in the ripple file for this directory (if does not exist -
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
             if ~isfile([basename '.ripples.events.mat'])
            	 PF_Preprocessing_Ripples 
             end
             load([basename '.ripples.events.mat']);
         % load in the sleep state mat (if does not exist - create it)
             if ~isfile([basename '_SleepState.analysis.mat'])
                lfp_chans2check = [10 30 60]; %make sure channels are good ones
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep2.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');      
             end 
             load([basename '_SleepState.analysis.mat']);
         % Find the time intervals for the sleep state(s) of interest
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
             % find how many ripples happen in each segment: find how many
             % ripples fall into each sleep segment, get the start and stop
             % times of those ripples, and finally calculate the number of
             % ripples and the ripple length
                 % Sleep 1
                    [sleep1_logical, ~, ~] = InIntervals(ripples.timestamps,  sleep1_intervals);
                    S1_ripples = ripples.timestamps(sleep1_logical,:);
                    [numRipples.S1,rippleLength.S1] = getNumAndLength_Ripples(S1_ripples);
                 % Sleep 2
                    [sleep2_logical, ~, ~] = InIntervals(ripples.timestamps,  sleep2_intervals);
                    S2_ripples = ripples.timestamps(sleep2_logical,:);
                    [numRipples.S2,rippleLength.S2] = getNumAndLength_Ripples(S2_ripples);
                 % Find total time in each sleep state
                    TotalTime.S1 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
                    TotalTime.S2 = sum(sleep2_intervals(:,2)-sleep2_intervals(:,1));
                 % Plot ripple rate for each sleep segment
                    plot(rippleRateFig,1, (numRipples.S1/TotalTime.S1), 'o','Color',color_all(irec,:));
                    hold(rippleRateFig,'on');
                    plot(rippleRateFig,2, (numRipples.S2/TotalTime.S2), 'o','Color',color_all(irec,:));
                 % save in mat
                    rippleRateMat(irec,1) = numRipples.S1/TotalTime.S1;
                    rippleRateMat(irec,2) = numRipples.S2/TotalTime.S2;
            % Plot length of sleep state for each sleep segment on a different
            % plot
                    plot(timeStateFig,1, TotalTime.S1, 'o', 'Color',color_all(irec,:));
                    hold(timeStateFig, 'on');
                    plot(timeStateFig,2, TotalTime.S2, 'o', 'Color',color_all(irec,:));
                    totalTimeMat(irec,1) = TotalTime.S1;
                    totalTimeMat(irec,2) = TotalTime.S2;
                    
    end
 % Plot ripple rate and time spent in sleep state
        title(rippleRateFig, [sleepQual ' Ripple Rate: VR/noVR (n=' num2str(length(recDir)) ')']);
        xlabel(rippleRateFig,'Sleep Session');
        ylabel(rippleRateFig,'Ripple Rate (ripples/s)');
        xlim(rippleRateFig,[0 5]);
        ylim(rippleRateFig,[0 1]);

        title(timeStateFig, [sleepQual ' Total Time: VR/noVR (n=' num2str(length(recDir)) ')']);
        xlabel(timeStateFig,'Sleep Session');
        ylabel(timeStateFig,'Time (s)');
        xlim(timeStateFig,[0 5]);
 % Make subplot of Ripple Rate and Total Time spent in sleep
        figure;
            subplot(1,2,1);
                boxplot(rippleRateMat);
                title([sleepQual ' Ripple Rate: VR/noVR (n=' num2str(length(recDir)) ')']);
                xlabel('Sleep Session');
                ylabel('Ripple Rate (ripples/s)');
            subplot(1,2,2);
                boxplot(totalTimeMat);
                title([sleepQual ' Total Time: VR/noVR (n=' num2str(length(recDir)) ')']);
                xlabel('Sleep Session');
                ylabel('Time (s)');

end