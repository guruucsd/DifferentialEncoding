% Test how adding multiple output units with the same value
%   affects training on the output
addpath('../sergent_1982');
clear all variables;

stats = {};
plts = {'ls-bars', stats{:}};

[args,opts] = uber_sergent_args('plots', plts,'stats', stats,'runs',25, ...
                                'deType', 'de-mtl');
% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
