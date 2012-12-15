% Christman (1991), identifying low frequency stimuli
[args,freqs] = christman_args();

[mSets, models, stats] = de_Simulator('christman_etal_1991', 'low_freq', 'recog', {'freqs', freqs}, args{:});
