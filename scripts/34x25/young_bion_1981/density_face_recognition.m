clear all variables; clear all globals;

stats = {'images','ffts'};
plts = stats;

[args,opts] = uber_face_args( 'plots',plts,'stats',stats,'runs',25,'distn',{'ipd'}, 'mu', [1.5 2], 'sigma', [5 5], 'nConns', 11, 'nHidden', 850*1, 'hpl', 1 );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'young_bion_1981/orig/recog', opts, args);
