function guru_saveall_figures(base_name, types, overwrite, dirpath, close_after)
    if ~exist('base_name','var'), base_name='Fig'; end;
    if ~exist('types', 'var'), types={'png'}; end;
    if ~iscell(types), types = {types}; end;
    if ~exist('overwrite','var'), overwrite=false; end;
    if ~exist('dirpath', 'var'), dirpath = pwd(); end;
    if ~exist('close_after', 'var'), close_after = false; end;

    % print all figures
    fh = get(0,'Children');
    suffs = zeros(size(types));

    warning('off', 'MATLAB:prnRenderer:opengl');
    for fi=1:length(fh);
        for ti=1:length(types)
            while true
                fn = fullfile(dirpath, sprintf('%s%01d.%s', base_name, fi+suffs(ti), types{ti}));
                if exist(fn) && ~overwrite, suffs(ti) = suffs(ti) + 1;
                else, break; end;
            end;
            if overwrite || ~exist(fn)
                fprintf('Saving figure %d to %s.\n', fh(fi), fn);
                switch types{ti}
                    case 'fig', saveas(fh(fi), fn, types{ti});
                    otherwise, export_fig(fh(fi), fn, '-painters');
                end;
                get(gcf, 'position')
            end;
        end;
        if close_after, close(fh(fi)); end;
    end;
