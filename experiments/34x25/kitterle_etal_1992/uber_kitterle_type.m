clear all variables; clear all globals;

[args, opts] = uber_kitterle_args();

[~, tst_type] = de_SimulatorUber('vanhateren/250', 'kitterle_etal_1992/sf_mixed/recog_type', opts, args);
