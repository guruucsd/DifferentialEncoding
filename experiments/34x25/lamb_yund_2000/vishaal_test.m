clear all variables; clear all globals;

stats = {};%'images','ffts'};
plts = {stats{:}};

[args,opts]  = uber_cbalanced_args('parallel', false, 'plots',plts, 'stats',stats, 'runs', 2, 'force', true);
opts = {opts{:}, 'b', true};

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('lamb_yund_2000/contrast-balanced', 'lamb_yund_2000/contrast-balanced', opts, args);
