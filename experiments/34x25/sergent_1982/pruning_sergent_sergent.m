% This script is for determining connections and initial weights based on the developmental / pruning procedure

clear all variables; clear all globals;
addpath(fullfile(fileparts(which(mfilename)), '..'));

stats = {'ipd','distns', 'images','ffts'};
plts = {'ls-bars', stats{:}};

[args,opts] = uber_sergent_args( 'plots', plts,'stats', stats,'runs',10 );
args        = pruning_args( args{:} );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
