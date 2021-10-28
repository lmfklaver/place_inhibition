function [VR_osci_rows, LT_osci_rows, OF_osci_rows] = getStdErrorPowerSpectra_PlaceInhibition(recDir, varargin)
% PURPOSE
%          Create a powerspectrum for each VR, OF, LT averaged over all
%          recording sessions and plotted with the standard error shading.
% INPUT
%          recDir          Array: Each cell has a pathway of a recording
%                                   session
%          movmean_win     Numeric: How much to smooth mean by, default
%                                     is 1
%          doSignificance  Boolean: Find significance (takes a long
%                                     time), default is false
%          withStdError    Boolean: Std error shading, default is true. If
%                                   false then just plot lines
% OUTPUT
%          VR_osci_rows    Matrix: (num exp x length(IRASA)) 
%          LT_osci_rows    Matrix:
%          OF_osci_rows    Matrix:
%          Plot of the mean power spectra of recording sessions with
%          standard error as shading. Compared VR, LT, and OF.
% DEPENDENCIES
%          Buzcode         https://github.com/buzsakilab/buzcode
%          TimeSegments mat   ([basename '_TimeSegments.analysis.mat'])
%          Ripples mat        ([basename '.ripples.analysis.mat'])
% CREDIT/REFERENCE
%          Simon Musall (2021). stdshade (https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade), 
%                               MATLAB Central File Exchange. Retrieved June 1, 2021.
% HISTORY
%          Reagan Bullins 06.01.2021
%% Input Parsers
    p = inputParser;
    addParameter(p,'movmean_win',1,@isnumeric);
    addParameter(p,'doSignificance',false,@islogical);
    addParameter(p,'withStdError',true,@islogical);
    parse(p,varargin{:});
    movmean_win = p.Results.movmean_win;
    doSignificance = p.Results.doSignificance;
    withStdError = p.Results.withStdError;
%% Define colors (sleep is warm colors, experiments are cool colors)
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3, 7, 11, 18
    color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)];%sleeps: 1, 5, 6, 7
    %2 = VR, 3 = OF, 4 = LT

%% Load each recording and define to new variable
IRASA_subset_mat = {};
for irec = 1:length(recDir)
   cd(cell2mat(recDir(irec)));
   basePath = cd;
   basename = bz_BasenameFromBasepath(basePath);
   % If there is not a IRASA subsection mat, make one (need to be same
   % length so we can find the standard error over them)
%    load([basename '_TimeSegments.analysis.mat']);
%    if ~isfile([basename '_IRASA_sub.analysis.mat'])
%         [Time_sub] = getSubsetTime(Time);
%         load([basename '.ripples.events.mat']);
%         lfp_channel = ripples.detectorinfo.detectionchannel; %0 based
%         [IRASA_subset] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time_sub, 'doLFPClean', false);
%         save([basename '_IRASA_sub.analysis.mat'], 'IRASA_subset');
%    end
%    load([basename '_IRASA_sub.analysis.mat']);
%    IRASA_subset_mat{irec} = IRASA_subset;
   load([basename '_TimeSegments.analysis.mat']);
   if ~isfile([basename '_IRASA.analysis.mat'])
        load([basename '.ripples.events.mat']);
        lfp_channel = ripples.detectorinfo.detectionchannel; %0 based
        [IRASA] = getPowerSpectrum_PlaceInhibition(basePath, lfp_channel, Time, 'doLFPClean', false, 'doSPlitLFP',true,'movmean_win',1);
        save([basename '_IRASA.analysis.mat'], 'IRASA');
   end
   load([basename '_IRASA.analysis.mat']);
   IRASA_subset_mat{irec} = IRASA;
end
IRASA_freq = IRASA_subset_mat{1}.specVR.freq; % assuming all frequencies are the same
%% Make a figure of mean VR, LT, and OF powerspecs across different sessions and graph with standard error
    figure;
% Make empty matrices, allocate space
    VR_osci_rows = zeros(length(recDir),length(IRASA_freq));
    LT_osci_rows = zeros(length(recDir),length(IRASA_freq));
    OF_osci_rows = zeros(length(recDir),length(IRASA_freq));
% Smooth the IRASA with movmean
    for irec = 1:length(recDir)
        VR_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specVR.osci, movmean_win)';
        LT_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specLT.osci, movmean_win)';
        OF_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specOF.osci, movmean_win)';
    end
    if withStdError
        % Graph the IRASA with standard error shaded across the sessions
            %VR
                stdshade(VR_osci_rows,.3, color_all(2,:));
                hold on;
            %LT
                stdshade(LT_osci_rows,.3, color_all(4,:));
            %OF
                stdshade(OF_osci_rows,.3, color_all(3,:));
        % Plotting
            legend( '','VR','','LT','','OF');
            xlabel('Frequency (Hz)');
            xticks([1 10000 20000 30000 40000]);
            xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
            ylabel('Power (mV)');
            title(['Mean Power Spectra (n=' num2str(length(recDir)) ')']);
            xlim([0 40000])
    elseif ~withStdError
        subplot(1,3,1);
            for iexp = 1:size(VR_osci_rows,1)
               plot(VR_osci_rows(iexp,:),'Color',color_all(2,:));
               hold on;
            end
                xlabel('Frequency (Hz)');
                xticks([1 10000 20000 30000 40000]);
                xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
                ylabel('Power (mV)');
                title('VR');
                xlim([0 40000])
                ylim([0 25]);
        subplot(1,3,2);
            for iexp = 1:size(LT_osci_rows,1)
               plot(LT_osci_rows(iexp,:),'Color',color_all(4,:));
               hold on;
            end
                xlabel('Frequency (Hz)');
                xticks([1 10000 20000 30000 40000]);
                xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
                ylabel('Power (mV)');
                title('LT');
                xlim([0 40000]);
                ylim([0 25]);
        subplot(1,3,3);
            for iexp = 1:size(OF_osci_rows,1)
               plot(OF_osci_rows(iexp,:),'Color',color_all(3,:));
               hold on;
            end
                xlabel('Frequency (Hz)');
                xticks([1 10000 20000 30000 40000]);
                xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
                ylabel('Power (mV)');
                title('OF');
                xlim([0 40000])
                ylim([0 25]);
         sgtitle(['Power Spectra (n=' num2str(length(recDir)) ')']);
    end
% Significance
    if doSignificance
        [sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500);
        [sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500);
        [sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500);
        save('sig_PowerSpecMean.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');
    end


end