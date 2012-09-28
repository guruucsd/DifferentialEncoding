clear all variables; clear all globals;

[args,opts]  = sergent_args();%'stats',{}, 'plots',{});

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent', opts, args);

