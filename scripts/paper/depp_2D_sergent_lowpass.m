% Model run with targets & distracters as specified by Sergent (1982)

args = depp_2D_args('ac.AvgError', 0.01, 'plots', {}, 'stats', {});

[mSets, models, stats] = DESimulatorHL(2, 'de', 'sergent', {'lowpass'}, args{:});

fprintf('avg iterations: RH=%4.1f, LH=%4.1f\n', mean(stats.rej.ti.AC{1}), mean(stats.rej.ti.AC{2}))
