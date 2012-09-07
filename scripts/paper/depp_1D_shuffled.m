% Model run with targets and distracter sets swapped

args = depp_1D_args();

DESimulatorHL(1, 'de', 'sergent', {'shuffled'}, args{:});
