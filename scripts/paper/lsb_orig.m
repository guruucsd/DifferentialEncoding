% replication of original 2D simulation
addpath(genpath('../../code'));


args = lsb_sets();

%de_StimCreateLSB(2, 'orig', 'recog', {'small'})

[mSets,plots,stats] = DESimulatorLSB(2, 'orig', 'recog', {'small.1'}, args{:});
