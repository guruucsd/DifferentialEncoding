% Kitterle (1992), classifying sin & square waves by frequency
[args,c_freqs,k_freqs]  = uber_args_34x25(  'runs', 20 );

[mSets, models, stats] = de_Simulator('uber', 'all', '', {'c_freqs', c_freqs, 'k_freqs', k_freqs, 'nInput', [34 25]}, args{:});

ac = [models(1,:).ac];
ac.fn
clear('ac');
