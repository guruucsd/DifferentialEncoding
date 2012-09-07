% Model run with targets & distracters as specified by Sergent (1982)

args = depp_2D_args();

[mSets, models, stats] = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
