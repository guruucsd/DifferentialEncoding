clear all variables; clear all globals;

stats = {}; % 'images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts] = uber_sergent_args('plots', plts,'stats',stats, 'runs', 50);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
