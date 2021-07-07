function [] = getRasterPlots_PlaceInhibition(basePath, pulseEpochs, exper_paradigm, cell_idx, varargin) 

%Purpose: Plots raster (cell spike times) for one specified cell around
%onset of opto stim (centered around zero) 


% Input:  basePath: path with data
%         pulseEpochs: start and stop times of pulses
%         exper_paradigm: string titling the pulse epochs you are giving the function (example:
%         'VR', 'OF','LT', or 'all'
%         cell_idx: cell index you want to plot
%         
% Output: Raster plot of specified cell (xaxis = time
% around pulse, yaxis = trial, dots = spikes)

% Reagan 2021.05.04
%%
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
        basename = bz_BasenameFromBasepath(basePath);
        load([basename '.spikes.cellinfo.mat']);
      %Plot raster of specified cell centered around pulse epochs
%         figure;
        timeEdges   = timwin(1):binSize:timwin(2);
        timeBefore  = abs(timwin(1));
        timeAfter   = timwin(2);
        trlCenteredEpochStart   = pulseEpochs(:,1)-timeBefore;
        trlCenteredEpochStop    = pulseEpochs(:,1)+timeAfter;
        trlCenteredEpoch = [trlCenteredEpochStart trlCenteredEpochStop];
        % Align the spikes to be centered around epoch start
        spike_toEpochStart = realignSpikes(spikes, trlCenteredEpoch);
%         figure;
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
