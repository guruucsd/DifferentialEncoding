clear all variables; clear all globals;

stats = {'paths'};%{'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('plots',plts,'stats',stats,'runs',2, 'ac.AvgError', 0, 'ac.MaxIterations', 500);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);
