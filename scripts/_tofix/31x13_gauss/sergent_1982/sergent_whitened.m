% Model run with targets and distracter sets swapped

args = sergent_args('ac.AvgError', 5E-6,        'ac.MaxIterations', 50, ...
                    'ac.TrainMode','resilient',  'ac.Pow', 3, ... %gradient power (usually 1)
                    'ac.EtaInit',  5E-2,         'ac.Acc', 1E-9, 'ac.Dec', 0.25, ... %tanh#2, bias=1 resilient
                    'ac.lambda',   0.05,  ...% regularization
                    'runs', 25, 'ac.absmean', 1.265E-02);
                    
%[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'dnw', true}, args{:});
