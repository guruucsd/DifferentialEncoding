clear all variables; clear all globals;

stats = {};%'ipd', 'ffts', 'distns', 'pca', 'images'};
plts = {'ls-bars'};%'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('deType', 'de-stacked', 'p.lambda', 0.01, ...
                                 'plots', plts, 'stats', stats, 'runs', 2);

% Make some things consistent across AC and P
ac_xferfn = guru_getopt(args, 'ac.XferFn', [6 1]);
args(end + [1:2]) = {'p.XferFn', [ac_xferfn(1) guru_getopt(args, 'p.XferFn', [6 3])]};
for prop = {'zscore', 'noise_input', 'wlim'}
    prop = prop{1};
    ac_val = guru_getopt(args, ['ac.' prop]);
    args(end + [1:2]) = {['p.' prop], ac_val};
end;

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
