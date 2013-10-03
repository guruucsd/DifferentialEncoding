function [args,opts] = classic_kitterle_args(varargin)
%

  % Get shared args
  addpath('..');
  [args,opts] = classic_args( ...
             'runs',    25, ...
             ...
             'p.XferFn', 6,               'p.useBias', 1, ...
                                          'p.nHidden', 100, ...
             'p.AvgError',  0,            'p.MaxIterations', 1500, ...
             'p.TrainMode','resilient',       'p.Pow',  1, ...
             ...'p.EtaInit',   2.2E-2,         'p.Acc',  1E-7,  'p.Dec',  0.25, ... %[ 328]: err = 4.1632e-01
             'p.EtaInit',   2.2E-2,         'p.Acc',  3E-6,  'p.Dec',  0.15, ... %kitterle_freq
             ...'p.EtaInit',   2E-3,         'p.Acc',  1E-8,  'p.Dec',  0.15, ... %[ 328]: err = 4.1632e-01
             ...'p.EtaInit',   2E-1,         'p.Acc',  1.0,  'p.Dec',  1.15, ... %sig,bias=0
             'p.lambda',   1E-3, ...
             'p.wmax', inf, ...
             ... %rejections
             'p.rej.props', {'err'}, ...
             'p.rej.type',  {'sample_std-normd'}, ...
             'p.rej.width', [3], ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
             'plots', {'ffts', 'images'}, ...
             'stats', {'ffts', 'images', 'ipd'}, ...
             varargin{:} ...
            );

  cycles = [5 12]; % are we sure about this?
  opts = {opts{:}, 'cycles', cycles};

