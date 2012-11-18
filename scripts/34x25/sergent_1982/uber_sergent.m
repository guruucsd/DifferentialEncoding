clear all variables; clear all globals;

[args,opts]  = sergent_args('plots',{'hu-encodings', 'hu-output','ls-bars','images','ffts','connectivity'}, 'stats',{'hu-encodings', 'hu-output','images','ffts','connectivity'});

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent',         opts, args);
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent-D1#T1',   opts, args);
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent-D1#T2',   opts, args);
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent-D2#T1',   opts, args);
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent-D2#T2',   opts, args);
[trn, tst] = de_SimulatorUber('uber/original', 'sergent_1982/de/sergent-swapped', opts, args);
