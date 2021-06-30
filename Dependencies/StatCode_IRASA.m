     % Load m246 only sessions
     load('IRASA_m246_allSessions.mat');
        [sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500);
        [sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500);
        [sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500);
        save('sig_PowerSpecMean_m246_allSessions.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');
        clear;
     %Load m247 sessions
      load('IRASA_m247_allSessions.mat');
        [sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500);
        [sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500);
        [sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500);
        save('sig_PowerSpecMean_m247_allSessions.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');
        clear;
     %Load all sessions
      load('IRASA_BothAnimals_allSessions.mat');
        [sig_VR_LT,stat_VR_LT]=do_perm(VR_osci_rows,LT_osci_rows, 500);
        [sig_VR_OF,stat_VR_OF]=do_perm(VR_osci_rows,OF_osci_rows, 500);
        [sig_LT_OF,stat_LT_OF]=do_perm(LT_osci_rows,OF_osci_rows, 500);
        save('sig_PowerSpecMean_BothAnimals_allSessions.mat','sig_VR_LT','stat_VR_LT','sig_VR_OF','stat_VR_OF','sig_LT_OF','stat_LT_OF');
        clear;