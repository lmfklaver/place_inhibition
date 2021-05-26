ssfigure
hold on
cell_idx = 1;
stimEpochs = stimEpochs_LT;

X = spikes.times{cell_idx};
Y = ones*length(spikes.times{cell_idx});

% check this 
XstimResp= stimEpochs;
YstimResp=repmat(-350,1,100);

XstimBox1 = XstimResp ;
XstimBox2 = XstimResp+0.3;
YstimBox1 = YstimResp - 25;
YstimBox2 = YstimResp +25;
% 

sliWin = 0.5;
start = 30;
stop = 30.5;

nr_fr = 100;

vidObj = VideoWriter('Test.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 7;
open(vidObj);
%set(gcf,'Visible', 'on')

set(gcf, 'Position', [1360 558 1916 428])
plot(X, Y,'k')
%plot(XstimResp,YstimResp, 'ro') % fill
%fill([XstimBox1; XstimBox1; XstimBox2; XstimBox2], [YstimBox1; YstimBox2; YstimBox2; YstimBox1], [0.015 0.5373 0.5373]);



for i = 1 : nr_fr
ylim([-10000 10000])
xlim([start start+5])
hold on
title('LFP and STIM')
frames(:, i) = getframe;
start = stop;
stop = stop+sliWin;
writeVideo(vidObj, getframe(gca));
end

%# save as AVI file, and open it using system video player
close(vidObj);
winopen('Test.avi')