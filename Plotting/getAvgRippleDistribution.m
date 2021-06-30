function [ripple_distribution_cumul] = getAvgRippleDistribution(recDir, segmentTitle, Time_sleep_sessions, varargin)
% PURPOSE
%          Create a ripple Distribution for each VR, OF, LT averaged over all
%          recording sessions and plotted with the standard error shading.
% INPUT
%          recDir          Array: Each cell has a pathway of a recording
%                                   session
%          segmentTitle    String: Either 'NREM','all','REM','wake',or
%                                  'exp', 'expSleep': Define what state you want to
%                                  average over
%          Time_sleep_sessions Matrix: Start and stop times of all sleep
%                                      times
%          doSignificance  Boolean: Find significance (takes a long
%                                     time), default is false
% OUTPUT
%          ripple_distribution_cumul Struct: each field is a cetain sleep session or
%                                            experiment session, each row
%                                            in the matrix within is a
%                                            different session
%          Plot of the mean ripple distribution of recording sessions with
%          standard error as shading. Compared VR, LT, and OF.
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          TimeSegments mat   ([basename '_TimeSegments.analysis.mat'])
%          Ripples mat        ([basename '.ripples.events.mat'])
%          Sleep state mat    ([basename '.SleepStates.states.mat'])
% CREDIT/REFERENCE
%          Simon Musall (2021). stdshade (https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade), 
%                               MATLAB Central File Exchange. Retrieved June 1, 2021.
% HISTORY
%          Reagan Bullins 06.25.2021
%% Input Parsers
    p = inputParser;
    addParameter(p,'doSignificance',false,@islogical);
    parse(p,varargin{:});
    doSignificance = p.Results.doSignificance;
%% Define colors (sleep is warm colors, experiments are cool colors)
if strcmp(segmentTitle, 'all') || strcmp(segmentTitle,'NREM') || strcmp(segmentTitle,'REM') || strcmp(segmentTitle,'wake') 
    warm_colors = hot(20); %3,7,10,12
    color_all = [warm_colors(3,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];
elseif strcmp(segmentTitle,'exp') || strcmp(segmentTitle, 'expSleep')
    cool_colors = cool(20);%3, 7, 11, 18 
    color_all = [cool_colors(3,:);cool_colors(7,:);cool_colors(11,:)];
end%2 = VR, 3 = OF, 4 = LT

%% Load each recording and define to new variable

for irec = 1:length(recDir)
   cd(cell2mat(recDir(irec)));
   basePath = cd;
   basename = bz_BasenameFromBasepath(basePath);
   % If there is not a IRASA subsection mat, make one (need to be same
   % length so we can find the standard error over them)
 
       load([basename '_TimeSegments.analysis.mat']);
       load([basename '.ripples.events.mat']);
       if strcmp(segmentTitle, 'exp')
          [rippleDistribution.exp] = getRippleDurationDistribution_SpecificExperiment(Time, ripples);
       elseif strcmp(segmentTitle,'expSleep')
          load([basename '.SleepState.states.mat']);
          [rippleDistribution.expSleep] = getRippleDurationDistribution_ExpPostSleep(SleepState.ints.NREMstate, Time, ripples);  
       else
           load([basename '.SleepState.states.mat']);
           [rippleDistribution.all] = getRippleDurationDistribution_SpecificSleepState(Time_sleep_sessions, Time, ripples);
           [rippleDistribution.NREM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.NREMstate, Time, ripples);
           [rippleDistribution.REM] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.REMstate, Time, ripples);
           [rippleDistribution.wake] = getRippleDurationDistribution_SpecificSleepState(SleepState.ints.WAKEstate, Time, ripples);
       end

   
   for isegment = 1:size(rippleDistribution.(segmentTitle),1)
       rip_mat_original = rippleDistribution.(segmentTitle)(isegment,:);
       ripple_distribution_cumul.(['segment' num2str(isegment)])(irec,:) = rip_mat_original;
   end
end
%% Make a figure of mean VR, LT, and OF ripple distributions across different sessions and graph with standard error
    figure;
        % Graph the ripple distribution with standard error shaded across the sessions
           for isegment = 1:size(rippleDistribution.(segmentTitle),1)
                stdshade(ripple_distribution_cumul.(['segment' num2str(isegment)]),.3, color_all(isegment,:));
                hold on;
           end

        % Plotting
            ylabel('Ripple ratio');
            xlabel('Ripple Length (s)');
            title(['Ripple Length Distribution(n=' num2str(length(recDir)) ')']);
 

 
% % Significance
%     if doSignificance
%         [sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500);
%         [sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500);
%         [sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500);
%         save('sig_PowerSpecMean.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');
%     end

end