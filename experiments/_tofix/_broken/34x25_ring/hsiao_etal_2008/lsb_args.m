function [args] = lsb_args(varargin)
%
%  Final shared settings for left-side-bias runs
  addpath(genpath('../../code'));

  args = de_ArgsInit ( ... %Network structure
         {   'runs',    5,          'ac.randState', 2,    'p.randState', 2, ...
             'distn',   {'normre'},  'mu',          1,    'sigma',       [ 0.5 1.5 ], ...
             'nHidden', 202,        'hpl',          1,    'nConns',      10, ...
             ...% Input
             'ac.tol',    4*34/25, ... %tolerance for disconnected pixels
             ... % Training
             'ac.XferFn',   6,            'ac.useBias',  0, ...
             'ac.AvgError', 0.01,         'ac.MaxIterations', 100, ...
             'ac.TrainMode','resilient',  'ac.Pow', 3, ... %gradient power (usually 1)
             'ac.EtaInit',  1E-4,         'ac.Acc', 5E-7, 'ac.Dec', 0.25, ... %tanh#2, bias=1 resilient
             'ac.lambda',   0.00,         ...% regularization
             'p.XferFn', 4,               'p.useBias', 1, ...
                                          'p.nHidden', 25, ...
             'p.AvgError',  0,            'p.MaxIterations', 1000, ...
             'p.TrainMode','resilient',   'p.Pow', 1, ... %gradient power (usually 1)
             'p.EtaInit',  1E-4,  'p.Acc', 1E-7,  'p.Dec', .15 ... %tanh#2,bias=1
...%             'p.TrainMode','batch',       'p.Pow', 1, ... %gradient power (usually 1)
...%             'p.EtaInit',  1E-5,  'p.Acc', 1+1E-5,  'p.Dec', 1.15 ... %tanh#2,bias=1
             'p.lambda',   0.01,         ...% regularization
             ... %rejections
             'ac.rej.props', {'err'},   'p.rej.props', {'err'}, ...
             'ac.rej.type',  {'max'},   'p.rej.type',  {'sample_std-normd'}, ...
             'ac.rej.width', [nan],     'p.rej.width', [3] ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
             'plots', {'ls-bars', 'images', 'ffts', 'connectivity'}, ...
             'stats', {'ffts'}, ...
         }, varargin{:} ); 
