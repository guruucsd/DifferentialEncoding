% Exploring all

args = depp_2D_args('nHidden', 22, 'nConns', 40); ms        = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 60); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 80); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 120); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 40); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 60); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 80); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 120); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 40); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 60); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 80); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 120); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 40); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 60); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 80); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 120); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 40); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 60); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 80); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 120); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});

% How to pull together all?
for i=1:length(ms)
    unix(['cp ' ms(i).out.files{end-1} ' .']);
    unix(['cp ' ms(i).out.files{end}   ' .']);
end;
