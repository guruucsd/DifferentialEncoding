function [cargs, opts] = uber_args(varargin)

  [cargs,opts] = common_args( ...
            'runs',    5, ...
            'errorType', 1, ...
            ...
            'ac.zscore', 0.05, ...
            'ac.TrainMode','resilient', ...
            'ac.Pow', 1, ... %gradient power (usually 1)
            'ac.XferFn',   [6 4],  ...
            'ac.AvgError', 1E-4, ...
            'ac.EtaInit', 5E-2, ...
            'ac.Acc', 5E-5, ...
            'ac.Dec', 0.25, ... %5E-7 tanh#2, bias=1 resilient
            'ac.MaxIterations', 100, ...
            ...
            'p.errorType', 3,... % cross-entropy
            'p.XferFn', [6 3], ...  %sigmoid->sigmoid
            'p.TrainMode', 'resilient', ...
            'p.EtaInit', 5E-2, ...
            'p.Acc', 1E-7, ...
            'p.Dec', 0.25, ...
            'p.dropout', 0.0, ...
              ...
             varargin{:} ...
           );
