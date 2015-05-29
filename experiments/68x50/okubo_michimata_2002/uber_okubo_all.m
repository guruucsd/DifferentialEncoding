clear all variables; clear all globals;

stats = {'ffts'};%images','ffts', 'distns', 'ipd'};
plts = {stats{:}};

[args,opts]  = uber_okubo_args('plots', plts,'stats',stats, 'runs', 25);

% Run sergent task by training on all images
[trn1, tst1] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/categorical', opts, args);
[trn2, tst2] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/coordinate', opts, args);
[trn3, tst3] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots-cb/categorical', opts, args);
[trn4, tst4] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots-cb/coordinate', opts, args);
keyboard
