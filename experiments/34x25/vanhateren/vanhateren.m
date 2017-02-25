stats = {'freqprefs'};%'ipd', 'ffts', 'distns'};
plts = {stats{:}};

[args, opts]  = vanhateren_args( ...
    'sigma', [1, 2, 4, 6, 8, 10], ...
    'nConns', 5, ...
    'parallel', false, ...
    'plots', plts, ...
    'stats',stats, ...
    'runs', 10 ...
);

% Run sergent task by training on all images
[mSets, models, stats] = de_Simulator('vanhateren', '250', '', opts, args{:});