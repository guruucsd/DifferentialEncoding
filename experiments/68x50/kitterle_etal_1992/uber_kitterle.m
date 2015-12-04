clear all variables; clear all globals;


stats={'images','connectivity','ffts'};
plots=stats;

[args,opts] = uber_kitterle_args( 'runs', 10, 'plots',plots,'stats', stats );
                           
[~, tst_freq] = de_SimulatorUber('uber/natimg', 'kitterle_etal_1992/sf_mixed/recog_freq', opts, args);
[~, tst_type] = de_SimulatorUber('uber/natimg', 'kitterle_etal_1992/sf_mixed/recog_type', opts, args);

kitterle_interaction_analysis(tst_freq, tst_type, ms, ss);

