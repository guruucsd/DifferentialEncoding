function args = depp_2D_args(varargin)
%
%  Final shared settings for 2YP runs
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));  
  
  
%  nHidden = 957; nConns = 7;
  
%  if (nHidden*nConns) < 
  
  args = de_ArgsInit ( ...
         {   'runs', 5, 'ac.randState', 2, 'p.randState', 2, ...
             'distn', {'norme'}, ...
             'mu',    [0], ...%[  0 0 0 0 0 0 0 0], ...%[0 0], ...
             'sigma', [1.5 3 5 8 12 15], ... %[1.5 2 3 4 5 6 7 8], ...%[3 5], ...
             ...
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
             'plots', {'images'}, 'stats', {}, ...
         }, varargin{:} ); 
