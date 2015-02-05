function img = guru_saveimages(out_path)
% Save all images with names

    if exist('out_path', 'var') && ~isempty(out_path)
        while ~isempty(findobj('type','figure'))
            if ~get(gcf, 'Name'), continue; end;
            export_fig(gcf, fullfile(out_path, sprintf('%s.png', get(gcf, 'Name'))), '-transparent');
            close(gcf);
        end;
    end;