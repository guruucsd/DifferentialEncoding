% replication of original 2D simulation
addpath(genpath('../../code'));

args = lsb_sets('p.MaxIterations', 'p.AvgError');

[mSets,plots,stats] = DESimulatorLSB(2, 'lsb_orig', 'recog', {'small.1'}, args{:}, 'plots', {'ffts'}, 'stats', {'ffts'}, 'p.MaxIterations', 100, 'p.AvgError', 0);
