% Kitterle (1992), classifying sin & square waves by frequency
[args,freqs] = kitterle_args( 'p.nHidden', 25, 'p.MaxIterations', 5000, ...
                 'p.EtaInit',  2E-2,         'p.Acc', 2E-6, 'p.Dec', 0.25, ... %tanh#2, bias=1 resilient
                 'p.lambda',   0.01         ...% regularization
              );

[mSets, models, stats] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {'freqs', freqs}, args{:});
