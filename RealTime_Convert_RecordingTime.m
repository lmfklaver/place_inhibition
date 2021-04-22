function [segmentTime] = RealTime_Convert_RecordingTime(basePath, SegmentStr)
%Purpose
    % Reads time from recording text file and converts to time since
    % beggining of recording
% Dependencies
    % basename_RecordingInfo.txt file (with start and stop times of each
    % recording segment. Time should be written in 00:00am/pm form or
    % 0:00am/pm form in text document. (time in 12 hour increments)
% Inputs
    % basePath: location of recording data 
    % SegmentStr: String of the name of the segment you want to idenitfy.
    % Should match the name labeling the time in the text document (but without spaces). Example
    % 'SleepTime1' or 'VRTime'
% Output
    % SegmentTime.Start - start time of segment in reference to recording start
    % SegmentTime.Stop  - stop time of segment in reference to recording
    % start

basename = bz_BasenameFromBasepath(basePath);
    
%Get starting time of recording
    rec_start.hour = str2double(basename(13:14));
    rec_start.min = str2double(basename(15:16));
    rec_start.sec = str2double(basename(17:18));
% Read in all of Recording Text File Information
    textContents = strjoin(textread([basename '_RecordingInfo.txt'], '%s'));
    textContents = textContents(find(~isspace(textContents)));
%% sleep1 start
        segment_idx = strfind(textContents, SegmentStr);
        segment_idx = segment_idx + length(SegmentStr);
        segment_start_str = textContents(1, segment_idx+1: segment_idx+7); %6 is the most a time can be 00:00p/a
        segment_start_hour = str2double(extractBefore(segment_start_str, ':'));
        segment_start_str_min = extractAfter(segment_start_str, ':');
            if contains(segment_start_str_min, 'a')
                    segment_start.min = str2double(extractBefore(segment_start_str_min,'a'));
                    segment_start.hour = segment_start_hour;
                elseif contains(segment_start_str_min, 'p')
                    segment_start.min = str2double(extractBefore(segment_start_str_min,'p'));
                    segment_start.hour = segment_start_hour + 12;
            end
        segment_hourDiff_inSec = (segment_start.hour - rec_start.hour) *3600; %hour to seconds
        segment_minDiff_inSec = (segment_start.min - rec_start.min) *60; %minutes to seconds
        
        rec_sec_total = (rec_start.hour*3600)+ (rec_start.min*60) + rec_start.sec;
        segment_sec_total = (segment_start.hour*3600) + (segment_start.min*60);
        
         if segment_minDiff_inSec + segment_hourDiff_inSec > 0
             segmentTime.start = segment_sec_total - rec_sec_total;
         elseif  segment_minDiff_inSec + segment_hourDiff_inSec == 0 
              segmentTime.start = 0;
         end
%% sleep1 stop
        segment_idx = strfind(textContents, SegmentStr);
        segment_idx = segment_idx + length(SegmentStr);
        segment_stop_str = textContents(1, segment_idx+8: segment_idx+14); 
        segment_stop_str_hour = (extractBefore(segment_stop_str, ':'));
        if contains(segment_stop_str_hour, '-')
            segment_stop_hour = str2double(segment_stop_str_hour(2:end)); 
        else
            segment_stop_hour = str2double(segment_stop_str_hour);
        end
        segment_stop_str_min = extractAfter(segment_stop_str, ':');
            if contains(segment_stop_str_min, 'a')
                    segment_stop.min = str2double(extractBefore(segment_stop_str_min,'a'));
                    segment_stop.hour = segment_stop_hour;
                elseif contains(segment_stop_str_min, 'p')
                    segment_stop.min = str2double(extractBefore(segment_stop_str_min,'p'));
                    segment_stop.hour = segment_stop_hour + 12;
            end
        segment_hourDiff_inSec = (segment_stop.hour - rec_start.hour) *3600; %hour to seconds
        segment_minDiff_inSec = (segment_stop.min - rec_start.min) *60; %minutes to seconds
       
        segment_stop_sec_total = (segment_stop.hour*3600) + (segment_stop.min*60);
        
         if segment_minDiff_inSec + segment_hourDiff_inSec > 0
             segmentTime.stop = segment_stop_sec_total - rec_sec_total;
         elseif  segment_minDiff_inSec + segment_hourDiff_inSec == 0 
              segmentTime.stop = 0;
         end
end