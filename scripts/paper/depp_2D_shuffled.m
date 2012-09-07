% Model run with targets and distracter sets swapped

args = depp_2D_args();

[mSets, models, stats] = DESimulatorHL(2, 'de', 'sergent', {'shuffled'}, args{:});
