% Run with stimuli as in Hsiao et al (2008)

args = depp_1D_args();

[mSets, models, stats] = de_SimulatorHL(1, 'de', 'sergent', {'reza-ized'}, args{:});
