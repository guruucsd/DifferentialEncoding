clear all variables; clear all globals;

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%

[args,opts] = christman_args( 'plots', {'hu-encodings', 'hu-output'}, 'stats',  {'hu-encodings', 'hu-output'} );
[mSets, models, stats] = de_Simulator('christman_etal_1991', 'high_freq', 'recog', {opts{:}}, args{:});

[~, tst_high] = de_SimulatorUber('uber/original', 'christman_etal_1991/low_freq/recog', opts, args);
[~, tst_low]  = de_SimulatorUber('uber/original', 'christman_etal_1991/high_freq/recog', opts, args);

% Reconstitute into expected format
%ms.freq = tst_freq.models;
%ms.type = tst_type.models;
%ss.freq = tst_freq.stats;
%ss.type = tst_type.stats;
%mSets   = tst_freq.mSets;

%ss.group = de_StatsGroupBasicsKit( mSets, ms, ss );

%de_PlotsGroupBasicsKit( mSets, ms, ss );
