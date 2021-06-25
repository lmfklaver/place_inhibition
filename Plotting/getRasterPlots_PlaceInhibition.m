function [] = getRasterPlots_PlaceInhibition(basePath, pulseEpochs, exper_paradigm, cell_idx, varargin) 
%PURPOSE
%          Plots raster (cell spike times) for one specified cell around
%          onset of opto stim (centered around zero) 
% INPUTS
%          basePath           String : path with data
%          pulseEpochs        Matrix : start and stop times of stim pulses
%          exper_paradigm     String : pulse epochs you are giving the function 
%                                      'noVR', 'VR', 'OF','LT', or 'all'
%          cell_idx           Numeric: cell index you want to plot
%          timwin             Vector : How much before and after to plot
%                                      around stim
%          binSize            Numeric: Bin size of raster
%         
% OUTPUT
%          Raster plot of specified cell (xaxis = time
%          around pulse, yaxis = trial, dots = spikes)
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan 05.04.2021
%% Input Parsers
p = inputParser;
addParameter(p,'basePath',basePath,@isstr);
addParameter(p,'pulseEpochs',pulseEpochs,@isnumeric);
addParameter(p, 'cell_idx',cell_idx, @isnumeric);
addParameter(p, 'exper_paradigm',exper_paradigm, @isstr);
addParameter(p,'timwin',[-0.4 0.4],@isvector);
addParameter(p,'binSize',0.01,@isnumeric);

parse(p,varargin{:});
basePath        = p.Results.basePath;
pulseEpochs     = p.Results.pulseEpochs;
cell_idx        = p.Results.cell_idx;
exper_paradigm  = p.Results.exper_paradigm;
timwin          = p.Results.timwin;
binSize         = p.Results.binSize;

%%
% Load spikes
    basename = bz_BasenameFromBasepath(basePath);
    load([basename '.spikes.cellinfo.mat']);
%Find time edges of points to plot
    timeEdges   = timwin(1):binSize:timwin(2);
    timeBefore  = abs(timwin(1));
    timeAfter   = timwin(2);
% Find the start and stop time to plot around the pulses
    trlCenteredEpochStart   = pulseEpochs(:,1)-timeBefore;
    trlCenteredEpochStop    = pulseEpochs(:,1)+timeAfter;
    trlCenteredEpoch = [trlCenteredEpochStart trlCenteredEpochStop];
% Align the spikes to be centered around epoch start
    spike_toEpochStart = realignSpikes(spikes, trlCenteredEpoch);
% For each epoch, align the epoch to zero, and then plot the spiking activity
    for iEpoch = 1:length(pulseEpochs)
       spikeTrl{iEpoch} = spike_toEpochStart{cell_idx}{iEpoch} - pulseEpochs(iEpoch,1);
       plot(spikeTrl{iEpoch}, iEpoch*ones(length(spikeTrl{iEpoch})),'.r');
       hold on;
    end 
    set(gca,'YDir','reverse')
    title(['Raster centered to' exper_paradigm ' stims: Cell ' num2str(cell_idx)])
    ylabel('Trial');
    xlabel('Time to Pulse(s)');
    xlim([timwin(1) timwin(2)]);
%         xaxis_limit = abs(timwin(1))*2*100;
%         num_axis_ticks = xaxis_limit/4;
%         xticks([0 num_axis_ticks num_axis_ticks*2 num_axis_ticks*3 xaxis_limit]);
%         xticklabels({num2str(timwin(1)*1000),num2str((timwin(1)*1000)/2),'0',num2str(abs((timwin(1)*1000)/2)),num2str(abs(timwin(1)*1000))});
end
