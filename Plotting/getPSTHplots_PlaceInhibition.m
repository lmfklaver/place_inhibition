function [] = getPSTHplots_PlaceInhibition(basePath, pulseEpochs, exper_paradigm, cell_idx, varargin)
% PURPOSE
%          Gets histograms of cell spikes centered around the onset of stim
%          pulses (time zero)
% INPUTS
%          basePath           String : path with data
%          pulseEpochs        Matrix : start and stop times of stim pulses
%          exper_paradigm     String : The experiment you are giving the function 
%                                    'noVR', 'VR', 'OF','LT', or 'all'
%          cell_idx           Numeric: cell index you want to plot
%         
% OUTPUT
%          Peristimulus time histogram of specified cell (xaxis = time
%          around pulse, yaxis = count)
% DEPENDENCIES
%          Buzcode            https://github.com/buzsakilab/buzcode
%          Utilities          https://github.com/englishneurolab/utilities
%          Place Inhibition   https://github.com/rcbullins/place_inhibition
% HISTORY
%          Reagan Bullins 05.04.2021
%% Input Parsers
p = inputParser;
addParameter(p,'basePath',basePath,@isstr);
addParameter(p,'pulseEpochs',pulseEpochs,@isnumeric);
addParameter(p, 'cell_idx',cell_idx, @isnumeric);
addParameter(p, 'exper_paradigm',exper_paradigm, @isstr);
addParameter(p,'timwin',[-0.4 0.4],@isvector);
addParameter(p,'binSize',0.01,@isnumeric);

parse(p,varargin{:});
basePath           = p.Results.basePath;
pulseEpochs        = p.Results.pulseEpochs;
cell_idx           = p.Results.cell_idx;
exper_paradigm     = p.Results.exper_paradigm;
timwin             = p.Results.timwin;
binSize            = p.Results.binSize;
%%
      basename = bz_BasenameFromBasepath(basePath);
      load([basename '.spikes.cellinfo.mat']);

% Perstimulus time histogram ONLY specified stim experiment 
     [peth] = getPETH_epochs(basePath,'epochs', pulseEpochs,'timwin',timwin, ...
        'binSize', binSize, 'saveMat', false);
      histogram('BinEdges', peth.timeEdges, 'BinCounts', peth.count(cell_idx,:));
      title(['PSTH centered to ' exper_paradigm ' stims: Cell' num2str(cell_idx)]);
      ylabel('Count');
      xlabel('Time to Pulse (s)');
      xlim([timwin(1) timwin(2)]);
      %xaxis_limit = abs(timwin(1))*2*100;
      %num_axis_ticks = xaxis_limit/4;
      %xticks([0 num_axis_ticks num_axis_ticks*2 num_axis_ticks*3 xaxis_limit]);
      %xticklabels({num2str(timwin(1)),num2str(timwin(1)/2),'0',num2str(abs(timwin(1))/2),num2str(abs(timwin(1)))});
end