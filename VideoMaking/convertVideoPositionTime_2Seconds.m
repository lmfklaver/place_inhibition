function [positionTimes_seconds] = convertVideoPositionTime_2Seconds(positionTimes)
   
% Purpose: Take in the position time strings outputted from bonsai and convert
% them to how many seconds since the beggining of the video as doubles

% Input: positionTimes (list of strings of time of position outputted from
% bonsai in excel sheet)

% Output: positionTimes_seconds (time converted to seconds)
% 6/10/21 Reagan

   positionTimes_seconds = zeros(length(positionTimes),1);
   for iframe = 1:size(positionTimes,1)
        segment_minutes = str2double(extractBefore(positionTimes(iframe,:), ':'));
        segment_seconds = str2double(extractAfter(positionTimes(iframe,:),':'));
        segment_secondsTotal = (segment_minutes*60)+segment_seconds;
        positionTimes_seconds(iframe,1) = segment_secondsTotal;
   end


end