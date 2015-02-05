% Model run with targets and distracter sets swapped
clear all variables; clear all globals;

[args,opt] = sergent_args('stats', {'images','ffts','ipd','err'}, 'plots', {'images','ffts','ls-bars','err', 'connectivity'});

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opt{:}}, args{:});
