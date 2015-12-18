clear all variables; clear all globals;

[args,opts]  = uber_okubo_args();

% Run sergent task by training on all images
[trn1, tst1] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/categorical', opts, args);
[trn2, tst2] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots/coordinate', opts, args);
[trn3, tst3] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots-cb/categorical', opts, args);
[trn4, tst4] = de_SimulatorUber('vanhateren/250', 'okubo_michimata_2002/dots-cb/coordinate', opts, args);

all_models = {tst1.models tst2.models tst3.models tst4.models};
all_mSets = {tst1.mSets tst2.mSets tst3.mSets tst4.mSets};

ss.group = de_StatsGroupBasicsOkubo(all_models, all_mSets);
figs = de_PlotsGroupBasicsOkubo(all_mSets, ss.group);

de_SavePlots(all_mSets{1}, figs);
