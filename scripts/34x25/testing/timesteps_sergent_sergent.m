% Try training a deep autoencoder, with each layer representing an image
addpath('../sergent_1982');
clear all variables;

stats = {'ipd','images','ffts'};
plts = {'ls-bars', stats{:}};
[args,opts] = uber_sergent_args('plots',plts,'stats',stats,'runs',25,'ac.AvgError', 2E-4, 'ac.MaxIterations', 200, 'ac.Acc', 5E-5);

% Run with ts=5
[trn5, tst5]  = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, {args{:}, 'ac.ts', 5});

% Run with ts=1
[args1,opts1] = uber_sergent_args('plots',plts,'stats',stats,'runs',2,'ac.ts', 1);
[trn1, tst1]  = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, {args{:}, 'ac.ts', 1});

% Compare!
%save('timesteps.mat','trn1','tst1','trn5','tst5');
