clear all variables; clear all globals;

stats = {'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_okubo_args('plots', plts,'stats',stats, 'runs', 2, 'ac.AvgError', 1E-3);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/categorical', opts, args);
