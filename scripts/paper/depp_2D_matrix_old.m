% Exploring all

args = depp_2D_args('nHidden', 22, 'nConns', 25); ms        = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 50); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 75); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 22, 'nConns', 125); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 25); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 50); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 75); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 24, 'nConns', 125); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 25); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 50); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 75); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 26, 'nConns', 125); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 25); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 50); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 75); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 28, 'nConns', 125); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 25); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 50); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 75); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 100); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});
args = depp_2D_args('nHidden', 30, 'nConns', 125); ms(end+1) = DESimulatorHL(2, 'de', 'sergent', {}, args{:});

% How to pull together all?
for i=1:length(ms)
    unix(['cp ' ms(i).out.files{end-1} ' .']);
    unix(['cp ' ms(i).out.files{end}   ' .']);
end;
