% Testing a new distribution, that only positions hidden units onto a grid
%   See if this still shows the frequency processing asymmetry
addpath('../sergent_1982');
clear all variables; clear all globals;

stats = {'ipd', 'connectivity', 'images', 'ffts', 'distns'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('parallel', true, 'plots',plts,'stats',stats,'runs',25,'distn',{'ipd'}, 'mu', [1.5 2], 'sigma', [5 5], 'nConns', 6, 'nHidden', 850, 'hpl', 1, 'ac.AvgError', 0, 'ac.MaxIterations', 30,'ac.rej.type','sample_std-normd','ac.rej.width',[2]);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);
