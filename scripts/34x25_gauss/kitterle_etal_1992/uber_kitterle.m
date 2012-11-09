clear all variables; clear all globals;

%%%%%%%%%%%%%%%%
% Run the autoencoder & gather output
%%%%%%%%%%%%%%%%%

[args,opts] = kitterle_args( 'runs', 5, 'plots', {'images', 'ffts'}, 'stats',  {'images','ffts'}, 'ac.zscore', 0.025, 'ac.EtaInit', 2E-1, 'ac.AvgError', 2E-4, 'ac.MaxIterations', 100,  ...
'errorType', 1, ...
                           'p.errorType', 3,... % cross-entropy
                           'p.XferFn', [6 3], ...  %sigmoid->sigmoid
                           'p.zscore', 0.15, ...
                           'p.EtaInit', 1E-3, ...
                           'p.dropout', 0, ...
                           'p.nHidden', 250, ...
                           'p.wmax', 2.0, ...
                           'p.MaxIterations', 500);
                           
[~, tst_freq] = de_SimulatorUber('uber/natimg', 'kitterle_etal_1992/sf_mixed/recog_freq', opts, args);
[~, tst_type] = de_SimulatorUber('uber/natimg', 'kitterle_etal_1992/sf_mixed/recog_type', opts, args);

% Reconstitute into expected format
ms.freq = tst_freq.models;
ms.type = tst_type.models;
ss.freq = tst_freq.stats;
ss.type = tst_type.stats;
mSets   = tst_freq.mSets;

ss.group = de_StatsGroupBasicsKit( mSets, ms, ss );

de_PlotsGroupBasicsKit( mSets, ms, ss );
