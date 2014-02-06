% Kitterle (1992), classifying sin & square waves by type (sin vs square)
clear all variables; clear all globals;
[args,opts] = kitterle_args();

[mSets, models, stats] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {opts{:}}, args{:});
