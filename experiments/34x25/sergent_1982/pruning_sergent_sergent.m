% This script is for determining connections and initial weights based on the developmental / pruning procedure

[args,opts] = uber_sergent_args();
args        = pruning_args( args{:} );

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
