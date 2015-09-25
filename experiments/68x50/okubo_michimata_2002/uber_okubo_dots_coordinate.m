clear all variables; clear all globals;

stats = {'images'};%'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_okubo_args('plots', plts,'stats',stats, 'runs', 25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/coordinate', opts, args);
