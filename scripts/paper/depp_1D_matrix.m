% Exploring all

args = depp_1D_args('nHidden', 11, 'nConns', 5); ms        = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 11, 'nConns', 6); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 11, 'nConns', 7); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 11, 'nConns', 8); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 11, 'nConns', 9); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 12, 'nConns', 5); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 12, 'nConns', 6); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 12, 'nConns', 7); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 12, 'nConns', 8); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 12, 'nConns', 9); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 13, 'nConns', 5); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 13, 'nConns', 6); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 13, 'nConns', 7); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 13, 'nConns', 8); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 13, 'nConns', 9); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 14, 'nConns', 5); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 14, 'nConns', 6); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 14, 'nConns', 7); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 14, 'nConns', 8); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 14, 'nConns', 9); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 15, 'nConns', 5); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 15, 'nConns', 6); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 15, 'nConns', 7); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 15, 'nConns', 8); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});
args = depp_1D_args('nHidden', 15, 'nConns', 9); ms(end+1) = DESimulatorHL(1, 'de', 'sergent', {}, args{:});

% How to pull together all?
for i=1:length(ms)
    unix(['cp ' ms(i).out.files{end-1} ' .']);
    unix(['cp ' ms(i).out.files{end}   ' .']);
end;
