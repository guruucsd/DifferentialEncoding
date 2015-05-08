clear all variables; clear all globals;
dbstop if error

stats = {'ipd', 'ffts', 'distns', 'pca', 'images'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_cbalanced_args('parallel', false, 'plots',plts, 'stats',stats, 'runs', 25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'lamb_yund_2000/contrast-balanced/de', opts, args);
