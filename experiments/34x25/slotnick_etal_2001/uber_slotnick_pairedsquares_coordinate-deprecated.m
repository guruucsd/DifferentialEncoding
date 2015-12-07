% This task is substantially harder, so we need more resources.
[args,opts]  = uber_slotnick_args('p.dropout', 0.0, 'p.nHidden', 20, 'p.MaxIterations', 200);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'slotnick_etal_2001/paired-squares/coordinate', opts, args);
