clear all variables; clear all globals;

stats = {'distns', 'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts] = uber_face_args( 'plots', plts,'stats', stats,'runs',25 );
[args]      = pruning_args( args{:} );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'young_bion_1981/orig/recog', opts, args);
