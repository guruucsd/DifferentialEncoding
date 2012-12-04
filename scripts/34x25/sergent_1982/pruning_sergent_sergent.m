clear all variables; clear all globals;

stats = {'distns', 'images','ffts'};
plts = {'ls-bars', stats{:}};

args        = pruning_args('plots',plts,'stats',stats,'runs',5);
[args,opts] = uber_sergent_args(args{:});

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/100', 'sergent_1982/de/sergent', opts, args);
