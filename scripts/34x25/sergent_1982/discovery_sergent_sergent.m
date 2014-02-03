% This script is for exploring parameters

clear all variables; clear all globals;

stats = {'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('parallel', false, 'plots',plts, 'stats',stats, 'runs', 25);%, 'ac.AvgError', 0, 'ac.MaxIterations', 500);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
