function guru_saveall_figures(results_dir, types, overwrite, close_after)
    if ~exist('types', 'var'), types={'png'}; end;
    if ~iscell(types), types = {types}; end;
    if ~exist('overwrite','var'), overwrite=false; end;
    if ~exist('close_after', 'var'), close_after = false; end;

    % print all figures
    fh = get(0,'Children');
    suffs = zeros(size(types)); %numbering figs

    %
    if ~exist(results_dir, 'dir'), mkdir(results_dir);

    warning('off', 'MATLAB:prnRenderer:opengl');
    for fi=1:length(fh);
        for ti=1:length(types)
            file_path = get_unique_filename(results_dir, get(gcf, 'name'), types{ti}, overwrite);

            if overwrite || ~exist(file_path)
                fprintf('Saving figure %d to %s.\n', fh(fi), file_path);
                figure(fh(fi));
                %set(fh(fi), 'PaperPositionMode', 'auto');
                pos = get(fh(fi), 'Position');
                set(fh(fi), 'PaperPosition', pos / 100);
                %get(fh(fi), 'position')
                switch types{ti}
                    case {'fig'}, saveas(fh(fi), file_path, types{ti});
                    case {'png'}, export_fig(file_path, '-painters');
                    otherwise, print(fh(fi), ['-d' types{ti}], file_path);
                end;
                get(fh(fi), 'position')
                get(fh(fi), 'paperposition')
            end;
        end;
        if close_after, close(fh(fi)); end;
    end;

function file_path = get_unique_filename(results_dir,figure_name, ext, overwrite, start_idx)
    if ~exist('start_idx', 'var')
        start_idx = 1;
    end;

    if isempty(figure_name)
        figure_name = 'fig';
    end;

    fi = start_idx;
    while true
        file_name = sprintf('%s%01d.%s', figure_name, fi, ext);
        file_path = fullfile(results_dir, file_name);
        if exist(file_path) && ~overwrite, fi = fi + 1;
        else, break; end;
    end;
