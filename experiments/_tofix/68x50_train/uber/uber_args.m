function [args,c_freqs,k_freqs,sz] = uber_args(varargin)
%
%  Final shared settings for 2YP runs

  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));  

  [cargs,sz] = common_args();
  rmpath('..');
    
c_freqs = 2*[0.03 0.06 0.12 0.24 0.48];
k_freqs = [0.05 0.15];

  args  = de_ArgsInit({ cargs{:}, ...
              'out.data', {'info','mat'}, ...
              'out.plots', {'png'},  ...
              'plots', {'images','ffts','connectivity'}, ...
              'stats', {'images','ffts'}, ... 

         }, varargin{:} ); 
                            
