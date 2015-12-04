[args,opts]  = uber_slotnick_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/paired-squares/coordinate', opts, args);
