[args,opts]  = uber_jonsson_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'jonsson_hellige_1986/HMTVWXY/samediff', opts, args);
