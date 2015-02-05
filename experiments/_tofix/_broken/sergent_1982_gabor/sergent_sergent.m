% Model run with targets and distracter sets swapped

args = sergent_args();

[mSets, models, stats] = de_Simulator('sergent_1982_gabor', 'de', 'sergent', {'nInput',[31 13 1 3]}, args{:});
