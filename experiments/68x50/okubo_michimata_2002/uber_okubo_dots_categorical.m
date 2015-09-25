clear all variables; clear all globals;

stats = {'images'};%'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_okubo_args('plots', plts,'stats',stats, 'runs', 25, 'ac.AvgError', 2E-4);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/categorical', opts, args);
