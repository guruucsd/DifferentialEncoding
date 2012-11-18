% Run with stimuli as in Hsiao et al (2008)

[args,sz] = sergent_args('plots', {'ls-bars'}, 'stats',{});

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz, 'D1#T1'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz, 'D1#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz, 'D2#T1'}, args{:}); %rezad
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz, 'D2#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'nInput', sz, 'swapped'}, args{:});

%de_SimulatorHL(2, 'de', 'dff', {},          args{:});
%de_SimulatorHL(2, 'de', 'gd', {},          args{:});
