% Testing what happens when we train to 'convergence'
addpath('../sergent_1982');
clear all variables; clear all globals;

stats = {'basics','ipd','images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('plots', plts,'stats', stats,'runs',25,'ac.AvgError', 0, 'ac.MaxIterations', 500,'ac.lambda', 0.0, 'ac.rej.type',{'sample_std-normd'},'ac.rej.width',[2], 'p.MaxIterations', 250);
% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
