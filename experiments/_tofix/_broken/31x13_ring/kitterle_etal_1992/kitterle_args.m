function [args,freqs] = kitterle_args(varargin)
%
%  Final shared settings for 2YP runs
  addpath(genpath('../../code/'));

  freqs = [0.05 0.15]; % are we sure about this?

  args = de_ArgsInit ( ... %Network structure
         {   'runs',    5,         'ac.randState', 2,    'p.randState', 2, ...
             'distn',   {'normre'}, 'mu',           0,    'sigma',       [ 1.5  3.0  6.0  11.0  18.0 ], ...
             'nHidden', 180,        'hpl',          3,    'nConns',      15, ...
             ...% Input
             'ac.tol',    0/403, ... %tolerance for disconnected pixels
             ... % Training: ac
             'ac.XferFn',   6,            'ac.useBias',  0, ...
             'ac.AvgError', 1E-4,        'ac.MaxIterations', 50, ...
             'ac.TrainMode','resilient',  'ac.Pow', 3, ... %gradient power (usually 1)
             'ac.EtaInit',  1E-4,         'ac.Acc', 5E-7, 'ac.Dec', 0.25, ... %tanh#2, bias=1 resilient
             'ac.lambda',   0.01,         ...% regularization
             ... % Training: p
             'p.nHidden', 25, ...
             'p.XferFn',   6,            'p.useBias',  1, ...
             'p.TrainMode','resilient',  'p.Pow', 1, ... %gradient power (usually 1)
             'p.EtaInit',  1E-4,         'p.Acc', 2E-8, 'p.Dec', 0.21, ... %tanh#2, bias=1 resilient
             'p.lambda',   0.01,         ...% regularization
             ... %rejections
             'ac.rej.props', {'err'},   'p.rej.props', {'err'}, ...
             'ac.rej.type',  {'max'},   'p.rej.type',  {'sample_std-normd'}, ...
             'ac.rej.width', [nan],     'p.rej.width', [3] ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
             'plots', {'ls-bars', 'images', 'ffts', 'connectivity'}, ...
             'stats', {'ffts','ipd'}, ...
         }, varargin{:} ); 
