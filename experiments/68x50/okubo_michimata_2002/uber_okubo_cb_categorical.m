[args,opts]  = uber_okubo_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots-cb/categorical', opts, args);
