% Model run with targets and distracter sets swapped
clear all variables;

[args,opts] = classic_sergent_args();
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:}}, args{:});
