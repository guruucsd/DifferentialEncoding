function guru_saveall_figures(base_name, types, overwrite, close_after)
    if ~exist('base_name','var'), base_name='Fig'; end;
    if ~exist('types', 'var'), types={'png'}; end;
    if ~iscell(types), types = {types}; end;
    if ~exist('overwrite','var'), overwrite=false; end;
    if ~exist('close_after', 'var'), close_after = false; end;

    % print all figures
    fh = get(0,'Children');
    suffs = zeros(size(types)); %numbering figs

    warning('off', 'MATLAB:prnRenderer:opengl');
    for fi=1:length(fh);
        for ti=1:length(types)
            fn = get_unique_filename(base_name, get(gcf, 'name'), types{ti}, overwrite);

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

function filename = get_unique_filename(base_name, figure_name, ext, overwrite, start_idx)
    if ~exist('start_idx', 'var')
        start_idx = 1;
    end;

    if ~isempty(figure_name)
        base_name = sprintf('%s_%s', base_name, figure_name);
    end;

    fi = start_idx;
    while true
        filename = sprintf('%s%01d.%s', base_name, fi, ext);
        if exist(filename) && ~overwrite, fi = fi + 1;
        else, break; end;
    end;
