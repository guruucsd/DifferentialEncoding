clear all variables; clear all globals;

stats = {};%'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_jonsson_args('parallel', false, 'plots',plts,'stats',stats, 'runs',2);%, 'ac.AvgError', 0, 'ac.MaxIterations', 500);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'jonsson_hellige_1986//',         opts, args);
