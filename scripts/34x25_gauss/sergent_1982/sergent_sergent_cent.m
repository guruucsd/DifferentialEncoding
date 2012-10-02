% Model run with targets and distracter sets swapped
clear all variables;

[args,opts] = sergent_args('p.XferFn', [4 3], ...%soft-max=>logistic
                           'p.errorType', 3,... % cross-entropy
                           'p.EtaInit', 5E-2, ...
                           'p.nHidden', 5, ...
                           'p.wmax', 2.0 ...
                           );
[mSets, models, stats] = de_Simulator('sergent_1982', 'sergent_1982', 'sergent', {opts{:}}, args{:});
