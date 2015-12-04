[args,opts]  = uber_han_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'han_etal_2003/cb/sergent', opts, args);
