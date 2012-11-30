% Testing a two-layer autoencoder; output connected to input as hidden
% normally would be to input.
addpath('../sergent_1982');
clear all variables; clear all globals;

stats = {};%'images', 'ffts'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('plots',plts,'stats',stats,'runs',25, ... 
                                 'distn', {'normem2'}, 'sigma', [2 4 6 8 12],  ...% normem2', ...
                                 'nHidden', 0, 'hpl', 0, 'ac.XferFn', [1], 'p.XferFn', [6 4]); %nHidden', 40, 'p.dropout', .5, 'p.TrainMode', 'resilient', 'p.EtaInit', .5E-2, 'p.Acc', 5E-6, 'p.Dec', 0.25, 'p.lambda', 0.005', 'p.XferFn', [6 4]); 
% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent-reza-ized',         opts, args);
