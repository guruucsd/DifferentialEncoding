% replication of original 2D simulation
args = depp_1D_args();

de_SimulatorHL(1, 'de', 'sergent', {},          args{:});
de_SimulatorHL(1, 'de', 'sergent', {'D1#T1'},   args{:});
de_SimulatorHL(1, 'de', 'sergent', {'D1#T2'},   args{:}); %rezad
de_SimulatorHL(1, 'de', 'sergent', {'D2#T1'},   args{:});
de_SimulatorHL(1, 'de', 'sergent', {'D2#T2'},   args{:});
de_SimulatorHL(1, 'de', 'sergent', {'swapped'}, args{:});
