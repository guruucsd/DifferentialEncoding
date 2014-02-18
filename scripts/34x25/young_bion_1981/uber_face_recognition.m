clear all variables; clear all globals;

stats = {};%'ffts'};
plts = {stats{:}};

[args,opts] = uber_face_args( 'plots',plts, 'stats',stats );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'young_bion_1981/orig/recog', opts, args);
