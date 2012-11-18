% Model run with targets and distracter sets swapped
clear all;
[args,sz] = sergent_args();

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz}, args{:});
