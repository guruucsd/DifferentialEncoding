clear all variables; clear all globals;


stats={}; %distns
plots=stats;

[args,opts] = uber_slotnick_args( 'plots', plots, 'stats', stats, 'runs', 5, 'ac.AvgError', 2E-4);

[~, tst_cate]  = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/blob-dot/categorical', opts, args);
[~, tst_coord] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/blob-dot/coordinate', opts, args);

% We should model code after: kitterle_interaction_analysis(tst_freq, tst_type);
slotnick_interaction_analysis(tst_cate, tst_coord);

