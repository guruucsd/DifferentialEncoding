function [args,opts,c_cycles,k_cycles] = uber_args(varargin)
%
%  Final shared settings for 2YP runs

  addpath('..');
  [cargs,opts] = common_args();
  rmpath('..');

c_cycles = [2 4 8 16 32];
k_cycles = [4 8];

  args  = de_ArgsInit(cargs{:}, ...
                  'out.data', {'info','mat'}, ...
                  'out.plots', {'png'},  ...
                  'plots', {'images','ffts','connectivity'}, ...
                  'stats', {'images','ffts'}, ...
                  varargin{:} );

