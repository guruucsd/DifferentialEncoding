% Christman (1991), identifying low frequency stimuli
[args,freqs] = christman_args( 'ac.MaxIterations', 350 );

[mSets, models, stats] = de_Simulator('christman_etal_1991', 'low_freq', 'recog', {'freqs', freqs, 'nInput', [34 25]}, args{:});
