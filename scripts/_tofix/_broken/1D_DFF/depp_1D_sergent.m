% Model run with targets & distracters as specified by Sergent (1982)

args = depp_1D_args();%'plots', {'ls-bars'});

[mSets, models, stats] = de_SimulatorHL(1, 'de', 'sergent', {}, args{:});
