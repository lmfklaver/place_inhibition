function [lfp_avg, pow_avg] = makePowersperc_Avg_MixedIntervalSizes(basePath,segment_intervals,lfp)
% Purpose: split lfp into specified time chunks (by timeMin) and average
% over all chunks

% Output:  A single vector of power, equal to the average of power over
% chunks of lfp

% Input: basePath (data location)
%        timeMin  (how long each chunk to average over is)
%        lfp      (lfp of data to chunk)
% Reagan Bullins 6/8/21
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