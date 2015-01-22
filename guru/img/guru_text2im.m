function img = guru_text2im(str, width, height, varargin)

    fh = figure('Visible', 'off'); 
    imagesc(0.5 * ones(height, width), [0 1]); colormap('gray');

    text(width/2, height/2, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', varargin{:});
    set(gca, 'xlim', [0 width], 'ylim', [0 height]);

    img = export_fig(fh);
    yidx = [1:height] + round((size(img,1) - height + 0.5)/2);
    xidx = [1:width] + round((size(img,2) - width + 0.5)/2);
    img = double(img(yidx, xidx)) / 255;
    close(fh);
