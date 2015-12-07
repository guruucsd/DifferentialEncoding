function [args,opts] = uber_kitterle_args(varargin)
%

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));

  stats = {};
  plots = {stats{:}};

  [args,opts] = uber_args( ...
      'runs',   20, ...
      'stats', stats, 'plots', plots, ...
      ...
      'sigma', [2 4 6 9 12 15 20], ...
      'p.zscore', 0.20, ...
      'p.TrainMode', 'resilient', ...
      'p.EtaInit', 1E-3, ...
      'p.Acc', 3E-6, 'p.Dec', 0.25, ...
      'p.XferFn', [8 3], ...  % logistic; binary classification
      'p.dropout', 0.5, ...
      'p.nHidden', 100, ...
      'p.wlim', 0.5*[-1 1], ...
      'p.lambda', 0.01,...
      'p.MaxIterations', 100, ...
      varargin{:} ...
  );

opts = {opts{:}, 'cycles', [2 5]};
