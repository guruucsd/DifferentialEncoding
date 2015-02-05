function guru_saveall_figures(results_dir, types, overwrite, close_after)
    if ~exist('types', 'var'), types={'png'}; end;
    if ~iscell(types), types = {types}; end;
    if ~exist('overwrite','var'), overwrite=false; end;
    if ~exist('close_after', 'var'), close_after = false; end;
    if ~exist(results_dir, 'dir'), mkdir(results_dir); end;

    % print all figures
    fh = unique(get(0, 'Children'));

    % Store figure sizes, as somehow they get
    %   reset during the print process
    %   when doing remotely, with no display set.
    positions = cell(size(fh));
    for fi=1:length(fh)
        positions{fi} = get(fh(fi), 'Position');
    end;

    warning('off', 'MATLAB:prnRenderer:opengl');
    for fi=1:length(fh);
        for ti=1:length(types)
            file_path = get_unique_filename(results_dir, get(fh(fi), 'name'), types{ti}, overwrite);

            if overwrite || ~exist(file_path)
                fprintf('Saving figure %d to %s.\n', fh(fi), file_path);
                copyfig(fh(fi)); close(fh(fi));
                set(gcf, 'PaperPositionMode', 'manual');
                set(gcf, 'PaperUnits', 'inches');
                set(gcf, 'PaperPosition', positions{fi}/100);
                set(gcf, 'Position', positions{fi});
                switch types{ti}
                    case {'fig'}, saveas(gcf, file_path, types{ti});
                    %otherwise, export_fig(gcf, file_path, '-transparent', '-painters');
                    otherwise, print(gcf, file_path, ['-d' types{ti}]);
                end;
            end;
        end;
        if close_after, close(gcf); end;
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
        file_name = sprintf('%s-%01d.%s', figure_name, fi, ext);
        file_path = fullfile(results_dir, file_name);
        if exist(file_path) && ~overwrite, fi = fi + 1;
        else, break; end;
    end;
