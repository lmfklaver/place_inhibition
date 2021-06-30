function [] = getIRASAPlot_VRnoVR(IRASA, Time, varargin)
% PURPOSE 
%          Makes power spectrum plot without fractals of VR/no VR experiment. Plots
%          segments in order of occurence. 
% INPUTS
%          IRASA
%               .specVR        Struct: .freq and .osci for Virtual reality 
%               .specnoVR      Struct: .freq and .osci for no Virtual
%                                                             reality           
%               .specS1        Struct: .freq and .osci for sleep 1
%               .specS2        Struct: .freq and .osci for sleep 2
%          Time                Struct: .start and .stop time structs 
%              .Sleep1
%              .Sleep2
%              .VR
%              .noVR
%          movmean_win   Numeric: default is 1, no smoothing window 
% OUTPUTS
%          Comprehensive plot with all segments
% HISTORY
%          Reagan Bullins 06.22.2021
%% Input Parsers
p = inputParser;
addParameter(p,'movmean_win',1,@isnumeric);
parse(p,varargin{:});
movmean_win      = p.Results.movmean_win;
%% Set colors for graphing - do not change 
% sleep colors are warm, experimental colors are cool
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3, 7, 11, 18
    color_all = [warm_colors(3,:);warm_colors(7,:);cool_colors(3,:);cool_colors(7,:)];

%%
%plot each experimental setup with the sleep directly before only
    max_pow(1) = max(movmean(IRASA.specVR.osci,movmean_win));
    max_pow(2) = max(movmean(IRASA.specS1.osci,movmean_win));
    max_pow(3) = max(movmean(IRASA.specS2.osci,movmean_win));
    max_pow(4) = max(movmean(IRASA.specnoVR.osci,movmean_win));
    max_ylim = max(max_pow)+2;

    %find which experiment happened first and compare it to sleep
    %session one
        figure;
        all_fig = axes;
        plot(all_fig, IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
        hold on;
        if (Time.VR.start < Time.noVR.start)
             plot(all_fig, IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(3,:));
             hold on
             plot(all_fig, IRASA.specnoVR.freq,movmean(IRASA.specnoVR.osci,movmean_win),'Color',color_all(4,:));
             exper_one = 'VR';
             exper_two = 'noVR';
        elseif (Time.noVR.start < Time.VR.start)
             plot(all_fig, IRASA.specnoVR.freq,movmean(IRASA.specnoVR.osci,movmean_win),'Color',color_all(4,:));
             hold on
             plot(all_fig, IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(3,:));
             exper_one = 'noVR';
             exper_two = 'VR';
        end
        plot(all_fig, IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(2,:));
        legend(all_fig,{'Pre Sleep',[exper_one],[exper_two],'Post Sleep'});
        xlabel(all_fig,'Frequency (Hz)');
        ylabel(all_fig,'Power (mV)');
        title(all_fig,'IRASA');
        xlim(all_fig,[0 50]);
        ylim(all_fig,[0 max_ylim]);
end