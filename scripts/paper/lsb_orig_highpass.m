% replication of original 2D simulation
addpath(genpath('../../code'));


args = lsb_sets('ac.AvgError', 0.0099);

%de_StimCreateLSB(2, 'orig', 'recog', {'small','highpass'})

[mSets,plots,stats] = DESimulatorLSB(2, 'orig', 'recog', {'small.highpass.1'}, args{:});
