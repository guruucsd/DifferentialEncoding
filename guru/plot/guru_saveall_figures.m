function guru_saveall_figures(base_name, type)
    if ~exist('base_name','var'), base_name='Fig'; end;
    if ~exist('type', 'var'), type='png'; end;

    % print all figures
    fh = get(0,'Children');
    for fi=1:length(fh);
    %    figure(fh);
        saveas(fh(fi), sprintf('%s%01d.%s', base_name, fh(fi), type), type);
    end;
