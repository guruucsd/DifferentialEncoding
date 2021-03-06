function [args,opts] = uber_okubo_args(varargin)
%

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));

  stats = {'images', 'ffts'};
  plots = {stats{:}};

  [args,opts] = uber_args( ... %Network structure
    'runs', 50, ...
    'stats', stats, 'plots', plots, ...
    ...
    'p.XferFn', [6 3], ...  %sigmoid->sigmoid
    'p.zscore', 0.05, ...
    'p.TrainMode', 'resilient', 'p.Pow', 1, ...
    'p.EtaInit', 2E-3, ...
    'p.Acc', 1E-4, 'p.Dec', 0.25, ...
    'p.nHidden', 20, ...
    'p.dropout', 0.5, ...
    'p.noise_input', 0.0, ...
    'p.wlim', 0.5*[-1 1], ...
    'p.MaxIterations', 100, ...
    'p.lambda', 0.01, ...
    'p.AvgError', 0, 'p.rej.width', [3], 'p.rej.type', {'sample_std-normd'}, ...
    varargin{:} ...
  );
