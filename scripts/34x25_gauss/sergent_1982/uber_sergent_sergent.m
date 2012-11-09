clear all variables; clear all globals;

plts = {'ls-bars'};
stats = {'images'};
[args,opts]  = sergent_args('plots',plts,'stats',stats,'runs',5, 'ac.zscore', 0.025, 'ac.EtaInit', 5E-1, 'ac.AvgError', 5E-4  );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);