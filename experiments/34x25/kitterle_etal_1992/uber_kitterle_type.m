[args, opts] = uber_kitterle_args('p.EtaInit', 3E-5, 'p.dropout', 0.0);

[~, tst_type] = de_SimulatorUber('vanhateren/250', 'kitterle_etal_1992/sf_mixed/recog_type', opts, args);
