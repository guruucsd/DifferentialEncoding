function guru_saveall_figures(base_name)
    if ~exist('base_name','var'), base_name='Fig'; end;
    
    % print all figures
    fh = get(0,'Children');
    for fi=1:length(fh);
    %    figure(fh);
        print(fh(fi), '-dpng', sprintf('%s%01d.png', base_name, fh(fi)));
    end;