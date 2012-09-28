clear all variables; clear all globals;

plts = {'hu-encodings', 'hu-output','ls-bars','images','ffts','connectivity'};
stats = {'hu-encodings', 'hu-output','images','ffts','connectivity'};
sigma = [1.5 3 5 7 10 15];
[args,opts]  = sergent_args('plots',plts,'stats',stats,'sigma',sigma,'runs',5);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent',         opts, args);