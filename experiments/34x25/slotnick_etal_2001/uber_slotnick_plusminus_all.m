clear all variables; clear all globals;


stats={}; %distns
plots=stats;

[args,opts] = uber_slotnick_args( 'plots', plots, 'stats', stats);

[~, tst_cate]  = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/plus-minus/categorical', opts, args);
[~, tst_coord] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/plus-minus/coordinate', opts, args);

% We should model code after: kitterle_interaction_analysis(tst_freq, tst_type);
slotnick_interaction_analysis(tst_cate, tst_coord);

