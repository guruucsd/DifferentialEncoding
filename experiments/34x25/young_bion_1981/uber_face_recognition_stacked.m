clear all variables; clear all globals;

stats = {'default', 'ffts'};%'ffts'};
plts = {'train-error', stats{:}};

[args,opts] = uber_face_args( 'plots',plts, 'stats',stats, 'deType', 'de-stacked' );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'young_bion_1981/orig/recog', opts, args);
