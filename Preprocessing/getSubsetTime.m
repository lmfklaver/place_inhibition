function [Time_sub] = getSubsetTime(Time, varargin)
% PURPOSE 
%          Make start and stop times for subset of bigger time intervals,
%          so that all segments are of equal length. Take every field of
%          Time struct and makes it of equal length
% INPUTS
%          Time                Struct: .start and .stop time structs 
%              .Event.start
%              .Event.stop
%              ...n events
%          sub_time_min        Numeric: Number of minutes to make subset
%                                       (default is 30 minutes)
%          sub_start_time_min  Numeric: How long into the sub section of
%                                       time to start subset of time
%                                       (default is 20 minutes)
% OUTPUTS
%          Time_sub            Struct: .start and .stop times
%              .Event.start
%              .Event.stop     (example.Sleep1,.Sleep2,.VR,.anything will
%                               work)
%          Buzcode       https://github.com/buzsakilab/buzcode
% HISTORY
%          Reagan Bullins 05.04.2021
%% Input Parsers
p = inputParser;
addParameter(p,'sub_time_min',30,@isnumeric);
addParameter(p,'sub_start_time_min',20, @isnumeric);
parse(p,varargin{:});
sub_time_min        = p.Results.sub_time_min;
sub_start_time_min  = p.Results.sub_start_time_min;
%%

    stringFields = fieldnames(Time);
    for ifield = 1:length(stringFields)
        Time_sub.(stringFields{ifield}).start = Time.(stringFields{ifield}).start + (sub_start_time_min*60);
        Time_sub.(stringFields{ifield}).stop = Time_sub.(stringFields{ifield}).start + (sub_time_min*60);
    end



end