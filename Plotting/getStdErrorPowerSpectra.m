warm_colors = hot(20); %3,7,10,12
cool_colors = cool(20);%3, 7, 11, 18
color_all = [warm_colors(3,:);cool_colors(3,:);cool_colors(7,:);cool_colors(11,:);warm_colors(7,:);warm_colors(10,:);warm_colors(12,:)]%sleeps: 1, 5, 6, 7
%2 = VR, 3 = Lt, 4 = OF
IRASA_freq = VR3.freq; %should be same freq for all
figure;
%VR
VR_osci_mean = movmean(mean([VR1.osci, VR2.osci, VR3.osci, VR4.osci],2),1000);
VR_osci_rows = [movmean(VR1.osci,1000)'; movmean(VR2.osci,1000)'; movmean(VR3.osci,1000)'; movmean(VR4.osci,1000)'];
stdshade(VR_osci_rows,.3, color_all(2,:));
xlim([0 49870])
hold on

%LT
LT_osci_mean = movmean(mean([LT1.osci, LT2.osci,LT3.osci, LT4.osci],2),1000);
LT_osci_rows = [movmean(LT1.osci,1000)'; movmean(LT2.osci,1000)';movmean(LT3.osci,1000)'; movmean(LT4.osci,1000)'];
stdshade(LT_osci_rows,.3, color_all(3,:));

%OF
OF_osci_mean = movmean(mean([OF1.osci, OF2.osci,OF3.osci, OF4.osci],2),1000);
OF_osci_rows = [movmean(OF1.osci,1000)'; movmean(OF2.osci,1000)';movmean(OF3.osci,1000)'; movmean(OF4.osci,1000)'];
stdshade(OF_osci_rows,.3, color_all(4,:));

%Plotting
legend( '','VR','','LT','','OF');
xlabel('Frequency (Hz)');
xticks([1 10000 20000 30000 40000]);
xticklabels({num2str(round(IRASA_freq(1)),2), num2str(round(IRASA_freq(10000),2)), num2str(round(IRASA_freq(20000),2)),num2str(round(IRASA_freq(30000),2)),num2str(round(IRASA_freq(40000),2))});
ylabel('Power (mV)');
title('Mean Power Spectra');

% significance
[sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500)
[sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500)
[sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500)

save('sig_PowerSpecMean.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');