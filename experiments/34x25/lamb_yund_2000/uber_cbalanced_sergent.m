clear all variables; clear all globals;

stats = {'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_cbalanced_args('parallel', false, 'plots',plts, 'stats',stats, 'runs', 5);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/100', 'lamb_yund_2000/contrast-balanced', opts, args);
