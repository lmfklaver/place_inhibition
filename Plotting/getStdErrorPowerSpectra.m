function [] = getStdErrorPowerSpectra(recDir)

% Purpose: Create a powerspectrum for each VR, OF, LT averaged over all
% recording sessions and plotted with the standard error shading.

% Credit: Simon Musall (2021). stdshade (https://www.mathworks.com/matlabcentral/fileexchange/29534-stdshade), MATLAB Central File Exchange. Retrieved June 1, 2021.

% Reagan 6.1.21 (uses Simon Musall's stdshade function to plot standard
% error as shaded region)
%%
p = inputParser;
addParameter(p,'movmean_win',1000,@isnumeric);
parse(p,varargin{:});
movmean_win = p.Results.movmean_win;

%% Define colors (sleep is warm colors, experiments are cool colors)
warm_colors = hot(20); %3,7,10,12
cool_colors = cool(20);%3, 7, 11, 18
color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
%2 = VR, 3 = Lt, 4 = OF

%% Load each recording and define to new variable
IRASA_subset_mat = {};
for irec = 1:length(recDir)
   cd(cell2mat(recDir(irec))) 
   basePath = cd;
   basename = bz_BasenameFromBasepath(basePath);
   load([basename '_IRASA_sub.analysis.mat']);
   IRASA_subset_mat{irec} = IRASA_subset;
end
IRASA_freq = IRASA_subset_mat{1}.specVR.freq; % assuming all frequencies are the same
%% Make a figure of mean VR, LT, and OF powerspecs across different sessions and graph with standard error
figure;

% make empty matrixes
    VR_osci_rows = zeros(length(recDir),length(IRASA_freq));
    LT_osci_rows = zeros(length(recDir),length(IRASA_freq));
    OF_osci_rows = zeros(length(recDir),length(IRASA_freq));
    
for irec = 1:length(recDir)
    VR_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specVR.osci, movmean_win)';
    LT_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specLT.osci, movmean_win)';
    OF_osci_rows(irec,:) = movmean(IRASA_subset_mat{irec}.specOF.osci, movmean_win)';
end

%VR
%VR_osci_rows = [movmean(VR1.osci,movmean_win)'; movmean(VR2.osci,movmean_win)'; movmean(VR3.osci,movmean_win)'; movmean(VR4.osci,movmean_win)'];
stdshade(VR_osci_rows,.3, color_all(2,:));

hold on

%LT
%LT_osci_rows = [movmean(LT1.osci,movmean_win)'; movmean(LT2.osci,movmean_win)';movmean(LT3.osci,movmean_win)'; movmean(LT4.osci,movmean_win)'];
stdshade(LT_osci_rows,.3, color_all(3,:));

%OF
%OF_osci_rows = [movmean(OF1.osci,movmean_win)'; movmean(OF2.osci,movmean_win)';movmean(OF3.osci,movmean_win)'; movmean(movmean_win,1000)'];
stdshade(OF_osci_rows,.3, color_all(4,:));

%Plotting
legend( '','VR','','LT','','OF');
xlabel('Frequency (Hz)');
xticks([1 10000 20000 30000 40000]);
xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
ylabel('Power (mV)');
title('Mean Power Spectra');

% significance
[sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500)
[sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500)
[sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500)

save('sig_PowerSpecMean.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');

end