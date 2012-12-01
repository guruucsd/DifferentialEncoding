clear all variables; clear all globals;

stats = {};%'connectivity', 'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts] = uber_sergent_args('plots',plts,'stats',stats,'runs',25 );
[args]      = pruning_args( args{:}, 'parallel', false );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/natimg', 'sergent_1982/de/sergent', opts, args);
