clear all variables; clear all globals;

stats = {'images','ffts'};
plts = {stats{:}};

[args,opts]  = uber_cbalanced_args('parallel', false, 'plots',plts, 'stats',stats, 'runs',25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/100', 'contrast-balanced', opts, args);
