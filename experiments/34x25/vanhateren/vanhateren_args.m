function [args, opts] = uber_vanhateren_args(varargin)
%

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));

  stats = {};
  plots = {stats{:}};

  [args,opts] = uber_args( ...
    'runs', 68, ...
    'stats', stats, 'plots', plots, ...
    ...
    varargin{:} ...
  );

  % Remove args for perceptron
  non_p_argname_idx = find(guru_findstr(args(1:2:end), 'p.')~=1);
  non_p_arg_idx = sort([2*non_p_argname_idx-1, 2*non_p_argname_idx]);
  args = args(non_p_arg_idx);

