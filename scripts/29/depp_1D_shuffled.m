% Model run with targets and distracter sets swapped

args = depp_1D_args();

de_SimulatorHL(1, 'de', 'sergent', {'shuffled'}, args{:});
