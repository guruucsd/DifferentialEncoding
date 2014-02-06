function guru_saveall_figures(base_name, type, overwrite)
    if ~exist('base_name','var'), base_name='Fig'; end;
    if ~exist('type', 'var'), type='png'; end;
    if ~exist('overwrite','var'), overwrite=true; end;
    
    % print all figures
    fh = get(0,'Children');
    for fi=1:length(fh);
    %    figure(fh);
        fn = sprintf('%s%01d.%s', base_name, fh(fi), type);
        if overwrite || ~exist(fn)
            saveas(fh(fi), fn, type);
        end;
    end;
