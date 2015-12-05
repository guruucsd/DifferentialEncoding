clear all variables; clear all globals;
[args,opts] = uber_sergent_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
