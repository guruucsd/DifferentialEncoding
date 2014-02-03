clear all variables; clear all globals;

stats = {}; % {'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('parallel', false, 'plots', plts, 'stats', stats, 'runs', 68);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent',         opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D1#T1',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D1#T2',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D2#T1',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-D2#T2',   opts, args);
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent-swapped', opts, args);
