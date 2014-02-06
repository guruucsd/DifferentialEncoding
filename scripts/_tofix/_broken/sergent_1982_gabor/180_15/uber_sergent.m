% Model run with targets and distracter sets swapped

args = uber_args('runs', 34 );

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {}, args{:});
