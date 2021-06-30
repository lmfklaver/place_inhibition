function [exper_order] = getExperimentalOrder_PlaceInhibition(Time)
% PURPOSE 
%          Find the order of events just for VR,LT,and OF experiments.
% INPUTS
%          Time      Struct: start and stop times of sleep and experiments
% OUTPUTS
%          exper_order Array: Array with strings labeling the
%                              experimental order
% HISTORY
%          Reagan Bullins 06.22.2021
%% See what experiment happened first, second, and third
exper_order = {};
    if (Time.VR.start < Time.OF.start && Time.VR.start < Time.LT.start)
         exper_order{1,1} = 'VR';
    elseif (Time.OF.start<Time.VR.start && Time.OF.start < Time.LT.start)
         exper_order{1,1} = 'OF';
    elseif (Time.LT.start < Time.VR.start && Time.LT.start< Time.OF.start)
         exper_order{1,1} = 'LT';
    end

    if (Time.VR.start < Time.OF.start && Time.VR.start > Time.LT.start || Time.VR.start > Time.OF.start && Time.VR.start < Time.LT.start)
         exper_order{1,2} = 'VR';
    elseif (Time.LT.start < Time.OF.start && Time.LT.start > Time.VR.start || Time.LT.start > Time.OF.start && Time.LT.start < Time.VR.start)
         exper_order{1,2} = 'LT';
    elseif (Time.OF.start < Time.LT.start && Time.OF.start > Time.VR.start || Time.OF.start > Time.LT.start && Time.OF.start < Time.VR.start)
         exper_order{1,2} = 'OF';
    end

    if (Time.VR.start > Time.LT.start && Time.VR.start > Time.OF.start)
         exper_order{1,3} = 'VR';
    elseif (Time.LT.start> Time.VR.start && Time.LT.start >Time.OF.start)
         exper_order{1,3} = 'LT';
    elseif (Time.OF.start > Time.VR.start && Time.OF.start >Time.LT.start)
         exper_order{1,3} = 'OF';
    end
end
