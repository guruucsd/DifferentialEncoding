function [h] = allometric_plot1(x,y,p,fns,fh,type,col,mark)
% x and y can be arrays, or they can be cell arrays of classes (with
% different colors)
%
% p and fn can be number/functions, or they can be arrays (different
% regressions for each class)

    if ~iscell(x), x=num2cell(x,1); end;
    if ~iscell(y), y=num2cell(y,1); end;
    if ~exist('fns','var')
        if exist('p','var'), error('cannot pass p but not fns');
        elseif iscell(x), [p,fns] = allometric_regression([x{:}],[y{:}]);
        end;
    end;
    if ~iscell(p), p=num2cell(p,2); end;
    if ~iscell(fns), fns=num2cell(fns,1); end;
    
    if ~exist('fh',  'var') || isempty(fh), fh = figure; end;
    if ~exist('col', 'var'), col='brgymcbrgymcbrgymcbrgymc'; end;
    if ~exist('mark','var'), mark='.ov^sd><p.ovtsd><p.ov^sd><p.ov^sd><p'; end;
    if ~exist('type','var'), type='loglog'; 
    elseif islogical(type) && type, type = 'loglog';
    elseif islogical(type) && ~type, type='linear'; 
    end;

    figure(fh); hold on; 
    set(gca, 'FontSize', 14);
    if strcmp(type, 'loglog'), set(gca, 'XScale', 'log', 'YScale', 'log'); end;
    
    for ci=1:length(x)
        
        % Determine the extent of the regression line
        if length(fns) == length(x) % per-class limit
            % Scatter points
%                        
            if strcmp(type, 'loglog'), h(ci) = scatter(x{ci}, y{ci}, 50, [mark(ci) col(ci)], 'LineWidth', 1.5);
            else,                      h(ci) = scatter(fns{ci}.xxform(x{ci}), fns{ci}.yxform(y{ci}), 50, [mark(ci) col(ci)], 'LineWidth', 1.5);
            end;
            
            if length(x{ci})==1, continue; end;
            xvals = sort(x{ci});
            xtvals = fns{ci}.xxform(xvals);
            rtvals = fns{ci}.reg(xvals); %
            rvals  = fns{ci}.yinv(rtvals);
            rcol = col(ci);
            
            % Plot the line
            if strcmp(type, 'loglog'), loglog(xvals, rvals, rcol, 'LineWidth', 1.5);
            else, plot(xtvals, rtvals, rcol, 'LineWidth', 1.5);
            end;
            
        else
            % Scatter points
            if strcmp(type, 'loglog'), h(ci) = loglog(x{ci}, y{ci}, [mark(ci) col(ci)], 'LineWidth', 1.5);
            else,                      h(ci) = plot(fns{1}(ci).xxform(x{ci}), fns{1}.yxform(y{ci}), [mark(ci) col(ci)], 'LineWidth', 1.5);
            end;
            
            %regression
            if ci==length(x)
                xvals = sort([x{:}]);
                xtvals = fns{1}.xxform(xvals);
                rtvals = fns{1}.reg(xvals);
                rvals  = fns{1}.yinv(rtvals);
                rcol= 'k';

                % Plot the line
                if strcmp(type, 'loglog'), loglog(xvals, rvals, rcol, 'LineWidth', 1.5);
                else, plot(xtvals, rtvals, rcol, 'LineWidth', 1.5); 
                end;
            end;
        end;

        
    end;
    
    
    reg_text = cell(size(p));
    for pi=1:numel(p)
        reg_text{pi} = guru_poly2text(p{pi});
    end;
    
    %if length(p)==1
        %title(['Regression: ' reg_text{1}]);
    %else
        legend(h, reg_text, 'Location', 'NorthWest');
    %end;
    
    
    % Give 25% padding
    if strcmp(type, 'loglog')
        axis tight;
        xl = get(gca, 'xlim'); yl = get(gca, 'ylim'); 
        xr = diff(xl); yr = diff(yl); r = max(xr,yr);

        padfactor = 10.^([-1 1]*diff(log10(yl))*.10);
        set(gca, 'xlim', xl.*padfactor, 'ylim', yl.*padfactor);
        
    % Square up dimensions
    else
        
        % Make sure the plot has square axes with comparable axis scaling
        xl = get(gca, 'xlim'); yl = get(gca, 'ylim'); 
        xr = diff(xl); yr = diff(yl); r = max(xr,yr);

        set(gca, 'xlim', xl(1)+[0 r]);
        set(gca, 'ylim', yl(1)+[0 r]);
    
        % Set x and y ticks to original units
        xt = get(gca, 'xtick'); yt = get(gca, 'ytick'); 
        xtlbl = guru_csprintf('%4.1E', fns{1}.xinv(xt));   ytlbl = guru_csprintf('%4.1E', fns{1}.yinv(yt));
        
        set(gca, 'xtick', xt, 'xticklabel', xtlbl, 'ytick',yt,'yticklabel',ytlbl);

    	axis square   
    end;
    