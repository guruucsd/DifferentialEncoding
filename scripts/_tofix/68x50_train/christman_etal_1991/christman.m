% Christman (1991), identifying low frequency stimuli
clear all variables; clear all globals;
[args,opts] = christman_args();

[mSets, ms.high, stats.high] = de_Simulator('christman_etal_1991', 'high_freq', 'high-recog', {opts{:}}, args{:});
[mSets, ms.low,  stats.low]  = de_Simulator('christman_etal_1991', 'low_freq',  'low-recog',  {opts{:}}, args{:});

%ss.group = de_StatsGroupBasicsSF( mSets, ms, ss );
%de_PlotsGroupBasicsSF( mSets, ms, ss );

