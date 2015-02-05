% Christman (1991), identifying low frequency stimuli
[args,freqs] = christman_args();

[mSets, models, stats] = de_Simulator('christman_etal_1991', 'all_freq', 'high-recog', {'freqs', freqs}, args{:});
[mSets, models, stats] = de_Simulator('christman_etal_1991', 'all_freq', 'low-recog',  {'freqs', freqs}, args{:});
