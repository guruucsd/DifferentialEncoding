% Christman (1991), identifying low frequency stimuli
clear all;
[args,opts] = christman_args();
[mSets, models, stats] = de_Simulator('christman_etal_1991', 'high_freq', 'recog', {opts{:}}, args{:});
