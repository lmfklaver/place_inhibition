function [spec_freq, spec_osci] = chunkLFP_takeOutFractals(lfp, varargin)
% PURPOSE 
%          Chunks lfp into 
% INPUTS
%          lfp           Struct
%          sizeChunk     Numeric: Number of samples per chunk
% OUTPUTS
%          spec_freq     Vector: Frequencies
%          spec_osci     Vector: Power of frequencies without fractals
% DEPENDENCIES
%          Buzcode       https://github.com/buzsakilab/buzcode
% HISTORY
%          Written by Lianne, implented by Reagan Bullins 06.28.2021 
%% Input Parser
p = inputParser;
addParameter(p,'sizeChunk',2500,@isnumeric);
parse(p,varargin{:});
sizeChunk     = p.Results.sizeChunk;
%% Chunking lfp data
        spec_freq =[];
        spec_osci = [];
        
        endId = 0;
        nChunks = floor(length(double(lfp.data))/sizeChunk);
        for iChunk = 1:nChunks
            if iChunk == 1;
            startId  = endId+1;
            else
            startId = endId-(sizeChunk/2)+1;%endId+1;
            end
            endId = endId+sizeChunk;
            selLFP = double(lfp.data(startId:endId));
            spec_temp = amri_sig_fractal(selLFP,1250,'detrend',1,'frange',[1 150]);
            spec_freq = [spec_freq;spec_temp.freq'];
            spec_osci = [spec_osci;spec_temp.osci']; 
        end

end
