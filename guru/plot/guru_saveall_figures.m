function guru_saveall_figures(base_name, types, overwrite, close_after)
    if ~exist('base_name','var'), base_name='Fig'; end;
    if ~exist('types', 'var'), types={'png'}; end;
    if ~iscell(types), types = {types}; end;
    if ~exist('overwrite','var'), overwrite=false; end;
    if ~exist('close_after', 'var'), close_after = false; end;

    % print all figures
    fh = get(0,'Children');
    suffs = zeros(size(types));

    warning('off', 'MATLAB:prnRenderer:opengl');
    for fi=1:length(fh);
        for ti=1:length(types)
            while true
                fn = sprintf('%s%01d.%s', base_name, fi+suffs(ti), types{ti});
                if exist(fn) && ~overwrite, suffs(ti) = suffs(ti) + 1;
                else, break; end;
            end;
            if overwrite || ~exist(fn)
                fprintf('Saving figure %d to %s.\n', fh(fi), fn);
                figure(fh(fi));
                %set(fh(fi), 'PaperPositionMode', 'auto');
                pos = get(fh(fi), 'Position');
                set(fh(fi), 'PaperPosition', pos / 100);
                %get(fh(fi), 'position')
                switch types{ti}
                    case {'fig', 'png'}, saveas(fh(fi), fn, types{ti});
                    otherwise, print(fh(fi), ['-d' types{ti}], fn); %export_fig(fn, '-painters');
                end;
                get(fh(fi), 'position')
                get(fh(fi), 'paperposition')
            end;
        end;
        if close_after, close(fh(fi)); end;
    end;
