% Kitterle (1992), classifying sin & square waves by frequency
[args,opts] = classic_kitterle_args( );

% Run the two tasks
[mSets, ms.freq, ss.freq] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {opts{:}}, args{:});
[mSets, ms.type, ss.type] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {opts{:}}, args{:});

%
ss.group = de_StatsGroupBasicsSF( mSets, ms, ss );

de_PlotsGroupBasicsSF( mSets, ms, ss );

