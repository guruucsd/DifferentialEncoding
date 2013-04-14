function [data,pix,xticks,yticks] = parse_img_by_color(img_file, data_colors, xtick_fn, ytick_fn)
%function [data,pix,xticks,yticks] = parse_img_by_color(img_file, data_colors, xtick_fn, ytick_fn)

% Assumes ...
%    if ~iscell(xticks_vals), xticks_vals = {xticks_vals}; end;
 %   if ~iscell(yticks_vals), xticks_vals = {yticks_vals}; end;
 
    if ~iscell(data_colors), data_colors = num2cell(data_colors); end;
    
    [yticks{1},yticks{2}]  = get_pixels_by_color(img_file, 'y'); %yticks = sort(yticks);  % 2 cols of them
    [xticks{1},xticks{2}]  = get_pixels_by_color(img_file, 'm'); %xticks = sort(xticks);

    pix = cell(length(data_colors),2);
    data = cell(size(pix));
    for ci=1:length(data_colors)
        [pix{ci,1},pix{ci,2}] = get_pixels_by_color(img_file, data_colors{ci});  % total fibers
    
        if exist('xtick_fn','var'), data{ci,2} = xtick_fn( (pix{ci,2}-xticks{2}(1))/mean(diff(xticks{2})) ); end;
        if exist('ytick_fn','var'), data{ci,1} = ytick_fn( (yticks{1}(end)-pix{ci,1})/mean(diff(yticks{1})) ); end;
        
        % Sort data based on x-values
        [data{ci,2},idx] = sort(data{ci,2});
        data{ci,1} = data{ci,1}(idx);
    end;
    
    