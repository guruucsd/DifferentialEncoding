% Kitterle (1992), classifying sin & square waves by frequency
clear all variables;
[args,opts] = kitterle_args('stats', {'ipd','err','ffts','images'}, 'plots',{'err','ffts','images'} );

% Run the two tasks
[mSets, ms.freq, ss.freq] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_freq', {opts{:}}, args{:});
[mSets, ms.type, ss.type] = de_Simulator('kitterle_etal_1992', 'sf_mixed', 'recog_type', {opts{:}}, args{:}, 'p.MaxIterations', 500);

%
ss.group = de_StatsGroupBasicsKit( mSets, ms, ss );

de_PlotsGroupBasicsKit( mSets, ms, ss );

