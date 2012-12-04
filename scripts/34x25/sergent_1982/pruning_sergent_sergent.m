clear all variables; clear all globals;

stats = {'distns', 'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts] = uber_sergent_args('plots',plts,'stats',stats,'runs',25, 'ac.EtaInit',1E-3,'sigma', [4 10]);
[args]      = pruning_args( args{:} );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/100', 'sergent_1982/de/sergent', opts, args);
