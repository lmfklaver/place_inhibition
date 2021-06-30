function [rippleRateMat,totalTimeMat, rippleRateExpTask] = getRippleRatePlots_PlaceInhibition(recDir, sleepQual)
% PURPOSE
%          This function is solely for the full day place inhibition experiments.
%          These experiments have a sequence of containing 4 sleep sessions, and 
%          3 experimental segments (linear track, virtual reality, and open
%          field)
%             
%          This function will create a series of figures to show ripple
%          rate in the different sleep sessions. Experimental sessions will
%          be grouped in two ways to show ripple rate:
%              - Sleep session by time of day (sleep 1, sleep 2, ...)
%              - Sleep session by task it follows (sleep after VR, sleep
%                after LT, sleep after OF)
%
% INPUTS   
%          recDir            Cell Array: Each cell contains a string of an
%                                        experimental session pathway
%          sleepQual         String    : Specify what you qualify as sleep
%                                      - NREM
%                                      - REM
%                                      - AllSleep
%
% OUTPUTS
%          rippleRateMat      Matrix   : (# recordings X # sleep sessions)
%          totalTimeMat       Matrix   : (# recordings X # sleep sessions)
%          rippleRateExpTask  Matrix   : (# recordings X # exp sessions)
%          Four figures
%              - Dot plots of ripple rate per experimental session
%              - Dot plots of length of time in sleep state per
%                experimental session
%              - Box plots of ripple rate and time spent in sleep state
%                over all sessions
%              - Box plots of ripple rate per sleep session and ripple rate
%                per sleep session following a specific task
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          Place Inhibition   https://github.com/rcbullins/place_inhibition
% TO DO   
%          Currently, throughout the place inhibtion scrips warm colors are
%          sleep and cool colors are behaviors, however this function has colors for
%          experimental session days. For these colors I am using the sleep and exp
%          colors -- THIS could get confusing.
%
% HISTORY
%           Reagan Bullins 06.21.2021

%% Set figure specs
% Figure for ripple rate in for loop
    figure(1);
        rippleRateFig = axes;
% Figure for time spent in sleep state in for loop
    figure(2);
        timeStateFig = axes;
% Colors to plot experimental days by
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3,7,11,12
    color_all = [warm_colors(3,:);cool_colors(3,:);warm_colors(7,:);cool_colors(7,:);warm_colors(10,:);cool_colors(11,:);warm_colors(12,:);cool_colors(12,:)];

% Allocate for speed
    rippleRateMat = zeros(length(recDir),4);
    totalTimeMat = zeros(length(recDir),4);
    rippleRateExpTask = zeros(length(recDir),3);
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
                    [Time.Sleep3] = RealTime_Convert_RecordingTime(cd, 'SleepTime3');
                    [Time.Sleep4] = RealTime_Convert_RecordingTime(cd, 'SleepTime4');
                    [Time.VR] = RealTime_Convert_RecordingTime(cd, 'VRTime');
                    [Time.OF] = RealTime_Convert_RecordingTime(cd, 'OFTime');
                    [Time.LT] = RealTime_Convert_RecordingTime(cd, 'LTTime');
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
                 [SleepState, SleepEditorInput] = PF_Preprocessing_SleepValidation(cd,lfp_chans2check, Time.Sleep1.start, Time.Sleep4.stop);      
                 save([basename '_SleepState.analysis.mat'],'SleepState','SleepEditorInput');
             end 
             load([basename '_SleepState.analysis.mat']);
         % Find the time intervals for the sleep state(s) of interest
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
                 % Sleep 3
                    [sleep3_logical, ~, ~] = InIntervals(ripples.timestamps, sleep3_intervals);
                    S3_ripples = ripples.timestamps(sleep3_logical,:);
                    [numRipples.S3,rippleLength.S3] = getNumAndLength_Ripples(S3_ripples);
                 % Sleep 4
                    [sleep4_logical, ~, ~] = InIntervals(ripples.timestamps, sleep4_intervals);
                    S4_ripples = ripples.timestamps(sleep4_logical,:);
                    [numRipples.S4,rippleLength.S4] = getNumAndLength_Ripples(S4_ripples);
                 % Find total time in each sleep state
                    TotalTime.S1 = sum(sleep1_intervals(:,2)-sleep1_intervals(:,1));
                    TotalTime.S2 = sum(sleep2_intervals(:,2)-sleep2_intervals(:,1));
                    TotalTime.S3 = sum(sleep3_intervals(:,2)-sleep3_intervals(:,1));
                    TotalTime.S4 = sum(sleep4_intervals(:,2)-sleep4_intervals(:,1));
                 % Plot ripple rate for each sleep segment
                    plot(rippleRateFig,1, (numRipples.S1/TotalTime.S1), 'o','Color',color_all(irec,:));
                    hold(rippleRateFig,'on');
                    plot(rippleRateFig,2, (numRipples.S2/TotalTime.S2), 'o','Color',color_all(irec,:));
                    plot(rippleRateFig,3, (numRipples.S3/TotalTime.S3), 'o','Color',color_all(irec,:));
                    plot(rippleRateFig,4, (numRipples.S4/TotalTime.S4), 'o','Color',color_all(irec,:));
                 % save in mat
                    rippleRateMat(irec,1) = numRipples.S1/TotalTime.S1;
                    rippleRateMat(irec,2) = numRipples.S2/TotalTime.S2;
                    rippleRateMat(irec,3) = numRipples.S3/TotalTime.S3;
                    rippleRateMat(irec,4) = numRipples.S4/TotalTime.S4;
            % Plot length of sleep state for each sleep segment on a different
            % plot
                    plot(timeStateFig,1, TotalTime.S1, 'o', 'Color',color_all(irec,:));
                    hold(timeStateFig, 'on');
                    plot(timeStateFig,2, TotalTime.S2, 'o', 'Color',color_all(irec,:));
                    plot(timeStateFig,3, TotalTime.S3, 'o', 'Color',color_all(irec,:));
                    plot(timeStateFig,4, TotalTime.S4, 'o', 'Color',color_all(irec,:));
                    totalTimeMat(irec,1) = TotalTime.S1;
                    totalTimeMat(irec,2) = TotalTime.S2;
                    totalTimeMat(irec,3) = TotalTime.S3;
                    totalTimeMat(irec,4) = TotalTime.S4;
             % save mat of tasks corresponding to sleep sessions (1 VR, 2
             % LT, 3 OF) *Reasoning: want to see if the expeirmental task
             % affects the ripple rate*
             %find first task (with sleep 2)
                if (Time.VR.start < Time.OF.start && Time.VR.start < Time.LT.start)
                    %VR
                    rippleRateExpTask(irec,1) = numRipples.S2/TotalTime.S2;
                elseif (Time.OF.start<Time.VR.start && Time.OF.start < Time.LT.start)
                    %OF
                     rippleRateExpTask(irec,2) = numRipples.S2/TotalTime.S2;
                elseif (Time.LT.start < Time.VR.start && Time.LT.start< Time.OF.start)
                    %LT
                     rippleRateExpTask(irec,3) = numRipples.S2/TotalTime.S2;
                end
             %find middle session (with sleep 3)
                if (Time.VR.start < Time.OF.start && Time.VR.start > Time.LT.start || Time.VR.start > Time.OF.start && Time.VR.start < Time.LT.start)
                    %VR
                    rippleRateExpTask(irec,1) = numRipples.S3/TotalTime.S3;
                elseif (Time.LT.start < Time.OF.start && Time.LT.start > Time.VR.start || Time.LT.start > Time.OF.start && Time.LT.start < Time.VR.start)
                    %LT
                     rippleRateExpTask(irec,3) = numRipples.S3/TotalTime.S3;
                elseif (Time.OF.start < Time.LT.start && Time.OF.start > Time.VR.start || Time.OF.start > Time.LT.start && Time.OF.start < Time.VR.start)
                    %OF
                     rippleRateExpTask(irec,2) = numRipples.S3/TotalTime.S3;
                end
             %find last session (with sleep 4)
                if (Time.VR.start > Time.LT.start && Time.VR.start > Time.OF.start)
                    %VR
                    rippleRateExpTask(irec,1) =  numRipples.S4/TotalTime.S4;
                elseif (Time.LT.start> Time.VR.start && Time.LT.start >Time.OF.start)
                    %LT
                     rippleRateExpTask(irec,3) = numRipples.S4/TotalTime.S4;
                elseif (Time.OF.start > Time.VR.start && Time.OF.start >Time.LT.start)
                    %OF
                     rippleRateExpTask(irec,2) = numRipples.S4/TotalTime.S4;
                end
                  
                    
    end
 % Plot ripple rate and time spent in sleep state
        title(rippleRateFig, [sleepQual ' Ripple Rate: Full Day (n=' num2str(length(recDir)) ')']);
        xlabel(rippleRateFig,'Sleep Session');
        ylabel(rippleRateFig,'Ripple Rate (ripples/s)');
        xlim(rippleRateFig,[0 5]);
        ylim(rippleRateFig,[0 1]);

        title(timeStateFig, [sleepQual ' Total Time: Full Day (n=' num2str(length(recDir)) ')']);
        xlabel(timeStateFig,'Sleep Session');
        ylabel(timeStateFig,'Time (s)');
        xlim(timeStateFig,[0 5]);
 % Make subplot of Ripple Rate and Total Time spent in sleep
        figure;
            subplot(1,2,1);
                boxplot(rippleRateMat);
                title([sleepQual ' Ripple Rate: Full Day (n=' num2str(length(recDir)) ')']);
                xlabel('Sleep Session');
                ylabel('Ripple Rate (ripples/s)');
            subplot(1,2,2);
                boxplot(totalTimeMat);
                title([sleepQual ' Total Time: Full Day (n=' num2str(length(recDir)) ')']);
                xlabel('Sleep Session');
                ylabel('Time (s)');
 % Make subplot of ripple rate over the sessions (boxplot 1 sleep in order of day...
                                                % boxplot 2 sleep in reference to task) 
        figure;
            subplot(1,2,1);
                boxplot(rippleRateMat(:,2:end));
                title([sleepQual ' Ripple Rate: Full Day (n=' num2str(length(recDir)) ')']);
                xticklabels({'Sleep 2','Sleep 3','Sleep 4'});
                xlabel('Time of Day Sleep');
                ylabel('Ripple Rate (ripples/s)');
            subplot(1,2,2);
                boxplot(rippleRateExpTask);
                title([sleepQual ' Ripple Rate: Full Day (n=' num2str(length(recDir)) ')']);
                xlabel('Sleep with exp task');
                ylabel('Ripple Rate (ripples/s)');
                xticklabels({'VR Sleep','LT Sleep','OF Sleep'});
end