% Run with stimuli as in Hsiao et al (2008)

args = depp_2D_args();

[mSets, models, stats] = DESimulatorHL(2, 'de', 'sergent', {'reza-ized'}, args{:});
