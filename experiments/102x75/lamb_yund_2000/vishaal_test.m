clear all variables; clear all globals;

stats = {'images','ffts'};
plts = {stats{:}};

[args,opts]  = uber_cbalanced_args('plots', plts, 'stats', stats, 'runs', 2);
opts = {'small', 'tweak_opt_val_to_redo', round(sum(clock()))};

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('sergent_1982/de', 'lamb_yund_2000/contrast-balanced/de', opts, args);
