function [lfpclean] = notchFilterMyLFP(lfp)

EEGAA = double(lfp.data);
lrSF = lfp.samplingRate;

   REMFREQ  = 60  ;     % [Hz]
   lrRemWid  = 0.5 ;     % [Hz]
   REMMULTI  = [ 1 3 5 ] ;
   lrSecWid   = 500 ;      
   
   [lfpclean] = XX_NotchFilter(EEGAA, lrSF, REMFREQ ,REMMULTI, lrRemWid, lrSecWid) ;
   end%if