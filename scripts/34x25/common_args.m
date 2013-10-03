function [cargs, opts] = common_args(varargin)

  % Add absolute path to code
  if (exist('de_GetBaseDir')~=2)
    addpath(genpath(fullfile('..','..', 'code')));
    addpath(genpath(fullfile('..','..','..', 'code')));
    addpath(genpath(fullfile(de_GetBaseDir(),'code')));
    rmpath (genpath(fullfile('..','..','..', 'code')));
    rmpath (genpath(fullfile('..','..', 'code')));
  end;

  opts = {'small'};

  cargs = {  'parallel', true, 'debug', 1:10, 'ac.debug', 1:10, 'p.debug', 1:10, ...
             'ac.randState', 2,   'p.randState', 2, ...
             'distn',   {'normem2'},     'mu',        0,  'sigma',       [ 0.6 4 10 160 ], ...
             'nHidden', 213*8,          'hpl',       8,    'nConns',      8, ...
             'deType', 'de', ...
             ...% Input
             'ac.zscore', 0.25, ...
             'ac.tol',    0*34/25, ... %tolerance for disconnected pixels
             ... % Training
             'ac.errorType', 2, ...
             'ac.XferFn',   [6 1], ...
             'ac.useBias',  1, ...
             ...
             'ac.WeightInitScale', 0.01, ...
             'ac.WeightInitType', 'sprandn', ...
             'ac.wlim',            [-inf inf], ...
             'ac.dropout', 0.0, ...
             'ac.noise_input',     0.00, ...
             'ac.lambda',          0.00,         ...% regularization
             ...
             'p.useBias',  1, ...
             ...
             'p.WeightInitScale', 0.10, ...
             'p.WeightInitType', 'sprandn', ...
             'p.wlim',            [-inf inf],         ...% regularization
             'p.dropout', 0.0, ...
             'p.noise_input',     0,         ...% regularization
             'p.lambda',          0.00,         ...% regularization
             ...
             'ac.rej.props', {'err'},                'p.rej.props', {'err'}, ... %err,max,nan
             'ac.rej.type',  {'max'},                'p.rej.type',  {'sample_std-normd'}, ...
             'ac.rej.width', [NaN],                  'p.rej.width', [2], ...%3] ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
              ...
             varargin{:}
           };
