function [avg_pow] = makePowerspec_AvgChunk_Vector(basePath, timeMin, lfp)
% Purpose: split lfp into specified time chunks (by timeMin) and average
% over all chunks

% Output:  A single vector of power, equal to the average of power over
% chunks of lfp

% Input: basePath (data location)
%        timeMin  (how long each chunk to average over is)
%        lfp      (lfp of data to chunk)
% Reagan Bullins 6/8/21
%% 
% Split lfp data into chunks
      [~, edges] = hist(lfp.timestamps, (1:timeMin:length(lfp.timestamps)));
% Make a start and stop of edges for lfp data (indexes)
      edges_lfp(1,:) = edges(1:end-1);
      edges_lfp(2,:) = edges(2:end);
% For each chunk, run a power spectrum of the chunk, and store it in a
% matrix to be averaged at the end
      for iseg = 1:size(edges_lfp,2)
          lfp_temp.timestamps = lfp.timestamps(edges_lfp(1, iseg):edges_lfp(2,iseg));
          lfp_temp.data = lfp.data(edges_lfp(1,iseg):edges_lfp(2,iseg));
          lfp_temp.samplingRate = lfp.samplingRate;
          [pow_temp] = getPowerSpectrum(basePath, lfp_temp, 'doIRASA', false, 'doPlot', false); 
          pow_mat(iseg,:) = pow_temp.fma.spectrum;
      end
          avg_pow.fma.spectrum = mean(pow_mat);
end