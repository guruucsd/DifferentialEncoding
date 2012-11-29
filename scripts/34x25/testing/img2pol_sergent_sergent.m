% Testing the effect of transforming the images to r/theta coordinates,
%   a la Plaut & Behrmann 2011
addpath('../sergent_1982');
clear all variables; clear all globals;

stats = {'paths','images','ffts'};%{'images','ffts'};
plts = {'ls-bars', stats{:}};

% because there are so many more grey pixels, and more redundancy, need to increase training
[args,opts]  = uber_sergent_args(plots',plts,'stats',stats,'runs',5, 'ac.AvgError', 5E-5,'nHidden',34*25,'hpl',1);
opts = {'small','location','LVF'};
% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', {opts{:}, 'img2pol'}, args);
