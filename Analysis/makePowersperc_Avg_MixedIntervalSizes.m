function [lfp_avg, pow_avg] = makePowersperc_Avg_MixedIntervalSizes(basePath,segment_intervals,lfp)
% PURPOSE
%          Split lfp into specified time chunks (by segment_intervals) and average
%          over all chunks. Find the smallest interval, and use that amount
%          to chunk the rest of the lfp. (All needs to be the same size to
%          average)
% INPUTS
%          basePath            String: path where data is located
%          segment_intervals   Matrix: (n x 2) start and stop times 
%          lfp                 Struct: Lfp of data to be chunked and
%                                      averaged
% OUTPUTS
%          lfp_avg             Vector: lfp average
%          pow_avg             Vector: power average
% DEPENDENCIES
%          Buzcode             https://github.com/buzsakilab/buzcode
%          English Utilities   https://github.com/englishneurolab/utilities
% HISTORY
%          Reagan Bullins 06.08.2021
%%
% find out the length of all the intervals trials are, THEN find the
% mininum length. The minimum interval size will be the size taken from all
% intervals because they need to be the same length.
      sec2take = min(segment_intervals(:,2)-segment_intervals(:,1))
      timeMin = 1250*sec2take;
% for each interval, find the lfp timestamps and data for that chunk and
% run a power spectrum of it, and then store it in a matrix
      lfp_avg_mat = zeros(size(segment_intervals,1),length(1:timeMin));
      for iseg = 1:size(segment_intervals,1)
          lfp_sub.timestamps = lfp(iseg).timestamps(1:timeMin); %segment_intervals(iseg,1):segment_intervals(iseg,1)+timeMin
          lfp_sub.data = lfp(iseg).data(1:timeMin) *.195;
          lfp_sub.samplingRate = lfp(iseg).samplingRate;
          [pow_temp] = getPowerSpectrum(basePath, lfp_sub, 'doIRASA', false, 'doPlot', false); 
          pow_mat(iseg,:) = pow_temp.fma.spectrum;
          lfp_avg_mat(iseg,:) = lfp(iseg).data(1:timeMin);
      end
% avg over matrix
      pow_avg.fma.spectrum = mean(pow_mat,1);
      lfp_avg = mean(lfp_avg_mat,1);

end