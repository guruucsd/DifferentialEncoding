% Christman (1991), identifying low frequency stimuli
[args,opts] = christman_args();

[mSets, models, stats] = de_Simulator('christman_etal_1991', 'low_freq', 'recog', {opts{:}}, args{:});
