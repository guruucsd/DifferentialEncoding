% Christman (1991), identifying low frequency stimuli
[args,freqs] = christman_args( 'ac.EtaInit', 0.025,  'ac.Acc', 1.01, 'ac.Dec', 1.25 ...  %sigmoid, bias=0
                              );

[mSets, models, stats] = de_Simulator('christman_etal_1991', 'all_freq', 'high-recog', {'freqs', freqs}, args{:});
[mSets, models, stats] = de_Simulator('christman_etal_1991', 'all_freq', 'low-recog',  {'freqs', freqs}, args{:});
