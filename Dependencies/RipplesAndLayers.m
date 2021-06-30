%% Get Ripple Laminae
% Script to determine center of PYR layer based on ripple amplitude

for iSess= sessions
    clear location 
    cd(dirN{iSess})
        %%

    basepath= cd; basename= bz_BasenameFromBasepath(basepath);
   sessionInfo = bz_getSessionInfo(basepath);
    load([basename '.spikes.cellinfo.mat']);
    load([basename '.ripples.events.mat']);
    % lfp = bz_GetLFP('all');
    %%
    % now just gets max ind of max ripple peak out , need to make this for four
    % cycles - will be slow
    % test with first and last 200 ripples
    
    % [pkValmaxInd, pkIndmaxInd, ripSnip] = findRippleLayerChan(lfp, ripples);
    %%
    selRipples = [1:200, length(ripples.timestamps)-200:length(ripples.timestamps)];
    [peakRipChan] = findRippleLayerChan(basepath, 'selRipples',selRipples);
%     [pkValmaxInd, pkIndmaxInd,ripSnip] = findRippleLayerChan(basepath, 'selRipples',selRipples);
    
    %%
%     [~,r] = max(pkValmaxInd);
    r = peakRipChan.pkInd;
    
%     figure,
%     
%     subplot(2,1,1)
%     histogram(r)
%     h = histogram(r,[(1:sessionInfo.nChannels)-0.5 +sessionInfo.nChannels+0.5]);
%     xlabel('channel')
%     ylabel('count')
%     % yline(10*std(h.Data)+mean(h.Data)) %???
%     %   legend({'max ripple amp','3*SD'})
%     
%     subplot(2,1,2)
%     plot(r,'o')
%     xlabel('ripple')
%     ylabel('channel')
%     
%     %
%     mode(r)
%     load('chanMap.mat');
%     [v,i] = sort(ycoords); % 1-indexed
%     chanMap(i);
    
[~,~,aacs] = splitCellTypes(basepath);
        
        numAAC = 0;
        for iAAC = aacs
            numAAC = numAAC +1;
            iAAC
            depthRipChan = ycoords(chanMap0ind==mode(r));
            aacChan = spikes.maxWaveformCh(iAAC);
            depthAACchan = ycoords(chanMap0ind==aacChan);
            
            diffChan = depthRipChan - depthAACchan;
            
            location.iAAC{numAAC} = iAAC;
            location.aacChan{numAAC} = aacChan;
            location.ripChan{numAAC} = mode(r);
            location.depthRipChan{numAAC} = depthRipChan;
            location.depthAACChan{numAAC} = depthAACchan;
            location.diffChan{numAAC}= diffChan;
            
            %         if depthAACchan > depthRipChan
            %             diffChan = - diffChan
            %         end
        end
        if ~isempty(aacs)
        save([basename '.location.mat'],'location')
        end
    end
    







