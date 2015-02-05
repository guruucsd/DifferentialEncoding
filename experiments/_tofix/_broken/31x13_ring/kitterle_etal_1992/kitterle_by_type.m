% Kitterle (1992), classifying sin & square waves by type (sin vs square)
[args,freqs] = kitterle_args( 'p.MaxIterations', 250, 'p.EtaInit', 0.01, 'p.alambda', 0.005 );

[mSets, models, stats] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {'freqs', freqs}, args{:});
