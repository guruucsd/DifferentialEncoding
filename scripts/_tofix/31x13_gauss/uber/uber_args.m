function [args,c_freqs,k_freqs] = uber_args(varargin)
%
%  Final shared settings for 2YP runs
  addpath(genpath('../../../code'));
  
%c_freqs = [0.03 0.06 0.12 0.24 0.48];
%c_freqs = [0.06 0.12 0.18 0.24 0.32];
%c_freqs = [0.06 0.12 0.24 0.48 0.96];
%  freqs = 2*[0.03 0.06 0.12 0.24 0.48]
%  freqs = 0.24*[1 2 4 8 16]%[0.24 0.48 0.96 1.5 2.6]
c_freqs = 0.02*[1 2 4 8 16];
k_freqs = [0.05 0.15];

  args  = de_ArgsInit({ ...
              'ac.randState', 600,  ...
              'distn', {'norme'}, ...
              'mu',    0, ...
              'sigma', [ 2.0  6.0  11.0 ], ...
              'nHidden', 90*4, 'hpl', 4, 'nConns', 8, ...
              ...
              ...%'ac.WeightInitScale', 0.10, 'p.WeightInitScale', 0.10, ...
              ...
              'ac.tol', 0, ...
              'ac.XferFn', 6, 'ac.useBias', 1, ...
              'ac.AvgError', 1E-4, 'ac.MaxIterations', 115, ...
              'ac.EtaInit',  1E-4,  'ac.Acc', 1E-6, 'ac.Dec', 0.15, ... %tanh#2, bias=1 resilient
              'ac.TrainMode','resilient', 'ac.Pow', 3, ...
              'ac.lambda', 0.02 ...%[0.02 0.02 0.015 0.01 0.005] ...
                   ...
              'ac.rej.props', {'err'}, ...
              'ac.rej.type',  {'max'}, ...
              'ac.rej.width', [nan],   ...
              ...
              'out.data', {'info','mat'}, ...
              'out.plots', {'png'}  ...
         }, varargin{:} ); 
                            