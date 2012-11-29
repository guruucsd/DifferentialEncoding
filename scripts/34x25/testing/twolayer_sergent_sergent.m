% Testing a two-layer autoencoder; output connected to input as hidden
% normally would be to input.
addpath('../sergent_1982');
clear all variables; clear all globals;

stats = {'images', 'ffts', 'distns'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('plots',plts,'stats',stats,'runs',2, ... 
                                 'distn', 'norme2', ...% normem2', ...
                                 'nHidden', 0, 'hpl', 0, 'ac.XferFn', [1], 'p.nHidden', 25, 'p.dropout', .5);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);
