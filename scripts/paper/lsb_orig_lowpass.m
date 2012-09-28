% replication of original 2D simulation
addpath(genpath('../../code'));


args = lsb_sets('ac.AvgError', 0.0049);

%de_StimCreateLSB(2, 'orig', 'recog', {'small','lowpass'})

[mSets,plots,stats] = DESimulatorLSB(2, 'orig', 'recog', {'small.lowpass.1'}, args{:});
