% replication of original 2D simulation
args = depp_1D_args();

DESimulatorHL(1, 'de', 'sergent', {},          args{:});
DESimulatorHL(1, 'de', 'sergent', {'D1#T1'},   args{:});
DESimulatorHL(1, 'de', 'sergent', {'D1#T2'},   args{:}); %rezad
DESimulatorHL(1, 'de', 'sergent', {'D2#T1'},   args{:});
DESimulatorHL(1, 'de', 'sergent', {'D2#T2'},   args{:});
DESimulatorHL(1, 'de', 'sergent', {'swapped'}, args{:});
