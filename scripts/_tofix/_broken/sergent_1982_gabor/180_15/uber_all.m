% Run with stimuli as in Hsiao et al (2008)

args = uber_args('runs', 50 );

[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T1'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'D1#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T1'}, args{:}); %rezad
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'D2#T2'}, args{:});
[mSets, models, stats] = de_Simulator('sergent_1982', 'de', 'sergent', {'swapped'}, args{:});
