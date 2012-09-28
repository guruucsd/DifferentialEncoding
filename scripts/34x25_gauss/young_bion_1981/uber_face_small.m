clear all variables; clear all globals;

[args,opts]  = face_args('plots', {}, 'stats', {});%'plots',{'hu-encodings', 'hu-output'}, 'stats',{'hu-encodings', 'hu-output'});

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/original', 'young_bion_1981/orig/recog', opts, args);

