% Run with stimuli as in Hsiao et al (2008)

args = sergent_args('plots', {'ls-bars'}, 'stats',{});
opts = {'nInput',[34 25]};

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:}}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:} 'D1#T1'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:} 'D1#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:} 'D2#T1'}, args{:}); %rezad
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:} 'D2#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {opts{:} 'swapped'}, args{:});

%de_SimulatorHL(2, 'de', 'dff', {},          args{:});
%de_SimulatorHL(2, 'de', 'gd', {},          args{:});
