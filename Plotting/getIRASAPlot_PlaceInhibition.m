function [] = getIRASAPlot_PlaceInhibition(IRASA,Time, varargin)
% PURPOSE 
%          Makes power spectrum plot without fractals of whole full day experiment. Plots
%          segments in order of occurence. 
% INPUTS
%          IRASA
%               .specVR        Struct: .freq and .osci for Virtual reality 
%               .specLT        Struct: .freq and .osci for linear track
%               .specOF        Struct: .freq and .osci for open field
%               .specS1        Struct: .freq and .osci for sleep 1
%               .specS2        Struct: .freq and .osci for sleep 2
%               .specS3        Struct: .freq and .osci for sleep 3
%               .specS4        Struct: .freq and .osci for sleep 4
%          Time                Struct: .start and .stop time structs 
%              .Sleep1
%              .Sleep2
%              .Sleep3
%              .Sleep4
%              .VR
%              .LT
%              .OF
%          movmean_win         Numeric: default is 1, no smoothing window 
% OUTPUTS
%          Comprehensive plot with all segments
%          A plot for VR, OF, and LT, all versus the sleep before the task
% HISTORY
%          Reagan Bullins 06.22.2021
%%
p = inputParser;
addParameter(p,'movmean_win',1,@isnumeric);
parse(p,varargin{:});
movmean_win      = p.Results.movmean_win;
%% Set colors for graphing - do not change 
% sleep colors are warm, experimental colors are cool
    warm_colors = hot(20); %3,7,10,12
    cool_colors = cool(20);%3, 7, 11, 18
    color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
%%
% Find the max power of each segment, to set axis the same
    max_pow(1) = max(movmean(IRASA.specVR.osci,movmean_win));
    max_pow(2) = max(movmean(IRASA.specLT.osci,movmean_win));
    max_pow(3) = max(movmean(IRASA.specOF.osci,movmean_win));
    max_ylim = max(max_pow)+10;

% Find which experiment happened first and compare it to sleep
% session one 
    figure;
        all_fig = axes;
        % Plot sleep 1
        plot(all_fig, IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
        hold on;
        % If VR is first
        if (Time.VR.start < Time.OF.start && Time.VR.start < Time.LT.start)
             figure;
             plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 1','VR'});
             title('IRASA 1:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specVR.freq(movmean(IRASA.specVR.osci,movmean_win) == (max(movmean(IRASA.specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_one = 'VR';
            % If OF is first
        elseif (Time.OF.start<Time.VR.start && Time.OF.start < Time.LT.start)
             figure;
             plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 1','OF'});
             title('IRASA 1:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specOF.freq(movmean(IRASA.specOF.osci,movmean_win) == (max(movmean(IRASA.specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(3,:));
             exper_one = 'OF';
            % If LT is first
        elseif (Time.LT.start < Time.VR.start && Time.LT.start< Time.OF.start)
             figure;
             plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
             hold on;
             plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 1','LT'});
             title('IRASA 1:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS1.freq,movmean(IRASA.specS1.osci,movmean_win),'Color',color_all(1,:));
                 hold on;
                 plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specLT.freq(movmean(IRASA.specLT.osci,movmean_win) == (max(movmean(IRASA.specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(4,:));
             exper_one = 'LT';
        end

        plot(all_fig, IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
        % find middle session and plot to sleep 2
        % If VR is the middle session
        if (Time.VR.start < Time.OF.start && Time.VR.start > Time.LT.start || Time.VR.start > Time.OF.start && Time.VR.start < Time.LT.start)
             figure;
             plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 2','VR'});
             title('IRASA 2:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specVR.freq(movmean(IRASA.specVR.osci,movmean_win) == (max(movmean(IRASA.specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_two = 'VR';
        % If LT is the middle session
        elseif (Time.LT.start < Time.OF.start && Time.LT.start > Time.VR.start || Time.LT.start > Time.OF.start && Time.LT.start < Time.VR.start)
             figure;
             plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 2','LT'});
             title('IRASA 2:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specLT.freq(movmean(IRASA.specLT.osci,movmean_win) == (max(movmean(IRASA.specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
             exper_two = 'LT';
        % If OF is the middle session
        elseif (Time.OF.start < Time.LT.start && Time.OF.start > Time.VR.start || Time.OF.start > Time.LT.start && Time.OF.start < Time.VR.start)
             figure;
             plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
             hold on;
             plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 2','OF'});
             title('IRASA 2:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS2.freq,movmean(IRASA.specS2.osci,movmean_win),'Color',color_all(5,:));
                 hold on;
                 plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specOF.freq(movmean(IRASA.specOF.osci,movmean_win) == (max(movmean(IRASA.specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
             exper_two = 'OF';
        end
        plot(all_fig, IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
    %find last session and plot to sleep 3
        % If VR is the last session
        if (Time.VR.start > Time.LT.start && Time.VR.start > Time.OF.start)
             figure;
             plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             legend({'Sleep 3','VR'});
             title('IRASA 3:Pre-Sleep vs VR');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specVR.freq(movmean(IRASA.specVR.osci,movmean_win) == (max(movmean(IRASA.specVR.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specVR.freq,movmean(IRASA.specVR.osci,movmean_win),'Color',color_all(2,:));
             exper_three = 'VR';
        % If LT is the last session
        elseif (Time.LT.start> Time.VR.start && Time.LT.start >Time.OF.start)
             figure;
             plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
             legend({'Sleep 3','LT'});
             title('IRASA 3:Pre-Sleep vs LT');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specLT.freq(movmean(IRASA.specLT.osci,movmean_win) == (max(movmean(IRASA.specLT.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specLT.freq,movmean(IRASA.specLT.osci,movmean_win),'Color',color_all(3,:));
             exper_three = 'LT';
        % If OF is the last session
        elseif (Time.OF.start > Time.VR.start && Time.OF.start >Time.LT.start)
             figure;
             plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
             hold on;
             plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
             legend({'Sleep 3','OF'});
             title('IRASA 3:Pre-Sleep vs OF');
             xlabel('Frequency (Hz)');
             ylabel('Power (mV)');
             ylim([0 max_ylim]);
             xlim([0 50]);
                 axes('Position',[.6 .4 .3 .3]);
                 box on;
                 plot(IRASA.specS3.freq,movmean(IRASA.specS3.osci,movmean_win),'Color',color_all(6,:));
                 hold on;
                 plot(IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
                 xlim([0 15]);
                 title(['MaxPeak: ' num2str(IRASA.specOF.freq(movmean(IRASA.specOF.osci,movmean_win) == (max(movmean(IRASA.specOF.osci,movmean_win)))))]);
                 hold off;
             plot(all_fig, IRASA.specOF.freq,movmean(IRASA.specOF.osci,movmean_win),'Color',color_all(4,:));
             exper_three = 'OF';
        end
          plot(all_fig, IRASA.specS4.freq,movmean(IRASA.specS4.osci,movmean_win),'Color',color_all(7,:));
          legend(all_fig,{'Sleep 1',[exper_one],'Sleep 2', [exper_two],'Sleep 3',[exper_three],'Sleep 4'});
          xlabel(all_fig,'Frequency (Hz)');
          ylabel(all_fig,'Power (mV)');
          title(all_fig,'IRASA');
          xlim(all_fig,[0 50]);
          ylim([0 max_ylim]);
end
