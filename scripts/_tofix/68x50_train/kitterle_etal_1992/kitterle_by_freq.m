% Kitterle (1992), classifying sin & square waves by frequency
clear all variables; clear all globals;
[args,opts] = kitterle_args( );

[mSets, models, stats] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {opts{:}}, args{:});
