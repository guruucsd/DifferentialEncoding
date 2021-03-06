function [args, opts] = uber_cbalanced_args(varargin)
%

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));

  stats = {'images', 'ffts'};
  plots = {'ls-bars', stats{:}};

  [args, opts] = uber_args( ... %Network structure
    'runs', 25, ...
    'stats', stats, 'plots', plots, ...
    'p.XferFn', [6 3], ...  %sigmoid->sigmoid
    'p.zscore', 0.10, ...
    'p.EtaInit', 2E-3, ...
    'p.TrainMode', 'resilient', ...
    'p.Acc', 1E-4, 'p.Dec', 0.25, ...
    'p.dropout', 0.0, ...
    'p.nHidden', 50, ...
    'p.wlim', 0.5*[-1 1], ...
    'p.MaxIterations', 100, ...
    'p.lambda', 0.01, ...
    varargin{:} ...
   );
