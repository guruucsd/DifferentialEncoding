% Run with stimuli as in Hsiao et al (2008)
clear all variables;

[args,opts] = sergent_args('plots', {'ls-bars'}, 'stats',{});

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent',         {opts{:}}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent-D1#T1',   {opts{:}}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent-D1#T2',   {opts{:}}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent-D2#T1',   {opts{:}}, args{:}); %rezad
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent-D2#T2',   {opts{:}}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent-swapped', {opts{:}}, args{:});

%de_SimulatorHL(2, 'de', 'dff', {},          args{:});
%de_SimulatorHL(2, 'de', 'gd', {},          args{:});
