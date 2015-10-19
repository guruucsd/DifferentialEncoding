clear all variables; clear all globals;

stats = {'images'};%'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_slotnick_args('plots', plts,'stats',stats, 'runs', 25, 'ac.AvgError', 2E-4);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/de/categorical', opts, args)
