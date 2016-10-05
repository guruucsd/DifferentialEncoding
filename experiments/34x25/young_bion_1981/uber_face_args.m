function [args,opts] = face_args(varargin)
%

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));

  stats = {'default', 'ffts'};
  plots = {'train-error', stats{:}};

  [args,opts] = uber_args( ...
    'runs', 25, ...
    'stats', stats, 'plots', plots, ...
    ...
    'p.XferFn', [6 7], ...  %sigmoid->sigmoid
    'p.zscore', 0.10, ...
    'p.EtaInit', 5.4E-3, ...
    'p.TrainMode', 'resilient', ...
    'p.Acc', 1E-6, ...
    'p.nHidden', 100, ...
    'p.MaxIterations', 200, ...
    varargin{:} ...
  );
