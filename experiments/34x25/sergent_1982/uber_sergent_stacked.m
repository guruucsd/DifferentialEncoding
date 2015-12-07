[args,opts]  = uber_sergent_args('deType', 'de-stacked', ...
                                 'p.MaxIterations', 25);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
