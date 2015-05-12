clear all variables; clear all globals;

stats = {'ipd', 'ffts', 'distns', 'pca', 'images'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('parallel', false, 'plots',plts, 'stats',stats, 'runs', 25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
