clear all variables; clear all globals;

stats =  {'ffts','images'};
plots = stats;

[args,opts] = uber_christman_args( 'runs', 10, 'plots', plots, 'stats', stats );

[~, tst_low]   = de_SimulatorUber('vanhateren/100', 'christman_etal_1991/low_freq/recog', opts, args);
[~, tst_high]  = de_SimulatorUber('vanhateren/100', 'christman_etal_1991/high_freq/recog', opts, args);

christman_interaction_analysis(tst_low, tst_high);
