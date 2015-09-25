clear all variables; clear all globals;

stats = {'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_okubo_args('plots', plts,'stats',stats, 'runs', 25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('okubo_michimata_2002/dots', 'okubo_michimata_2002/dots/categorical', opts, args);
