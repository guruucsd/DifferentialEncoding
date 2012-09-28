clear all variables; clear all globals;

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%

[args,opts] = kitterle_args( 'plots', {'hu-encodings', 'hu-output'}, 'stats',  {'hu-encodings', 'hu-output'} );

[~, tst_freq] = de_SimulatorUber('uber/original', 'kitterle_etal_1992/sf_mixed/recog_freq', opts, args);
[~, tst_type] = de_SimulatorUber('uber/original', 'kitterle_etal_1992/sf_mixed/recog_type', opts, args);

% Reconstitute into expected format
ms.freq = tst_freq.models;
ms.type = tst_type.models;
ss.freq = tst_freq.stats;
ss.type = tst_type.stats;
mSets   = tst_freq.mSets;

ss.group = de_StatsGroupBasicsKit( mSets, ms, ss );

de_PlotsGroupBasicsKit( mSets, ms, ss );
