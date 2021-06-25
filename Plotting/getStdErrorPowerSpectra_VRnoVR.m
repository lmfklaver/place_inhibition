function [] = getStdErrorPowerSpectra_VRnoVR(recDir, varargin)
% PURPOSE  Create a powerspectrum for VR and no VR, with standard error
%          shading over all recording sessions in directory.
%
% INPUT
%          recDir          Array: Each cell has a pathway of a recording
%                                   session
%          movmean_win     Numeric: How much to smooth mean by, default
%                                     is 1
%          doSignificance  Boolean: Find significance (takes a long
%                                     time), default is false
%         withStdError     Boolean: Plot with shaded error bars, default is
%                                   true
% OUTPUT
%          Plot of the mean power spectra of recording sessions with
%          standard error as shading.
% DEPENDENCIES
%          Buzcode         https://github.com/buzsakilab/buzcode
% CREDIT 
%          Simon Musall (2021). stdshade (https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade), 
%                               MATLAB Central File Exchange. Retrieved June 1, 2021.
% HISTORY
%          Reagan 06.01.2021 
%% Input Parsers
p = inputParser;
addParameter(p,'movmean_win',1,@isnumeric);
addParameter(p,'doSignificance',false,@islogical);
addParameter(p,'withStdError',true,@islogical);
parse(p,varargin{:});
movmean_win    = p.Results.movmean_win;
doSignificance = p.Results.doSignificance;
withStdError   = p.Results.withStdError;
%% Define colors (sleep is warm colors, experiments are cool colors)
warm_colors = hot(20); %3,7,10,12
cool_colors = cool(20);%3, 7, 11, 18
color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
%VR = 2, no VR = 3

%% Load each recording and define to new variable
IRASA_subset_mat = {};
for irec = 1:length(recDir)
   cd(cell2mat(recDir(irec))) 
   basePath = cd;
   basename = bz_BasenameFromBasepath(basePath);
   % If there is not a IRASA subsection mat, make one (need to be same
   % length so we can find the standard error over them)
   load([basename '_TimeSegments.analysis.mat']);
   if ~isfile([basename '_IRASA_sub.analysis.mat'])
        [Time_sub] = getSubsetTime(Time);
        load([basename '.ripples.events.mat']);
        lfp_channel = ripples.detectorinfo.detectionchannel; %0 based
        [IRASA_subset] = getPowerSpectrum_VRnoVR(basePath, lfp_channel, Time_sub, 'doLFPClean', false, 'doSplitLFP', false, 'movmean_win', 1000);
         save([basename '_IRASA_sub.analysis.mat'], 'IRASA_subset');
   end
   load([basename '_IRASA_sub.analysis.mat']);
   IRASA_subset_mat{irec} = IRASA_subset;
end
IRASA_freq = IRASA_subset_mat{1}.specVR.freq; % assuming all frequencies are the same
%% Make a figure of mean VR, LT, and OF powerspecs across different sessions and graph with standard error
    figure;
% Make empty matrices, allocate space
    VR_osci_rows = zeros(length(recDir),length(IRASA_freq));
    noVR_osci_rows = zeros(length(recDir),length(IRASA_freq));
    
% Smooth the IRASA with movmean
    for irec = 1:length(recDir)
        VR_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specVR.osci, movmean_win)';
        noVR_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specnoVR.osci, movmean_win)';
    end
if withStdError
    % Graph the IRASA with standard error shaded across the sessions
        %VR
            stdshade(VR_osci_rows,.3, color_all(2,:));
            hold on;
        %no VR
            stdshade(noVR_osci_rows,.3, color_all(3,:));
    % Plotting
        legend( '','VR','','no VR');
        xlabel('Frequency (Hz)');
        xticks([1 10000 20000 30000 40000]);
        xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
        ylabel('Power (mV)');
        title('Mean Power Spectra');
elseif ~withStdError
    subplot(1,2,1);
            for iexp = 1:size(VR_osci_rows,1)
               plot(VR_osci_rows(iexp,:),'Color',color_all(2,:));
               hold on;
            end
            xlabel('Frequency (Hz)');
            xticks([1 10000 20000 30000 40000]);
            xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
            ylabel('Power (mV)');
            title('VR');
    subplot(1,2,2);
            for iexp = 1:size(noVR_osci_rows,1)
               plot(noVR_osci_rows(iexp,:),'Color',color_all(3,:));
               hold on;
            end
            xlabel('Frequency (Hz)');
            xticks([1 10000 20000 30000 40000]);
            xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
            ylabel('Power (mV)');
            title('no VR');
            
            sgtitle(['Power Spectra (n=' num2str(length(recDir)) ')']);
end

% Significance
    if doSignificance
        [sig_VR_noVR,stat_VR_noVR]=do_perm(VR_osci_rows,noVR_osci_rows, 500);
        save('sig_PowerSpecMean.mat','sig_VR_noVR','stat_VR_noVR');
    end


end