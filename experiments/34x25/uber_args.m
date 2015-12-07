function [cargs, opts] = uber_args(varargin)

  [cargs, opts] = common_args( ...
    'ac.zscore', 0.20, ...
    'ac.TrainMode','resilient', ...
    'ac.AvgError', 0, ...
    'ac.EtaInit', 5E-3, ...
    'ac.Acc', 1E-6, ...
    'ac.Dec', 0.25, ... %5E-7 tanh#2, bias=1 resilient
    'ac.MaxIterations', 50, ...
    'ac.lambda', 0.01, ...
    'ac.noise_input', 2.0, ...
    'ac.wlim', 0.25 * [-1 1], ...
    'ac.rej.width', [3], 'ac.rej.type', {'sample_std'}, ...
    ...
    'p.TrainMode', 'resilient', ...
    'p.EtaInit', 5E-2, ...
    'p.Acc', 1E-7, ...
    'p.Dec', 0.25, ...
    ...
    varargin{:} ...
);


opts = {opts{:}};
