function dirname = r_out_paths(type)
    base_dir = fullfile(fileparts(which(mfilename)), '..');
    switch type
        case 'runs'
            dirname = fullfile(base_dir,'runs');
        otherwise
            dirname = guru_getOutPath(type);
    end;
