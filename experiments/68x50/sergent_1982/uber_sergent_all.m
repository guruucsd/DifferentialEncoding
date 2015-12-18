clear all variables; clear all globals;

[args,opts]  = uber_sergent_args();

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D1#T1',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D1#T2',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D2#T1',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D2#T2',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-swapped', opts, args);
