function fh = allometric_plot2(xvals,yvals,pplt,gplt,type,fh)
%

%
if ~exist('type','var'), type={'loglog','linear'}; end;
if ~iscell(type), type={type}; end;
nsubs = numel(type);

%
if ~exist('fh','var'), 
    if   nsubs==1, fh = figure('Position',     [360   162   826   516]);
    else           fh = figure('Position', [16         139        1265         545]);
    end;
end;
figure(fh);

%
xvsteps = linspace(min(xvals)*0.75, max(xvals)*1.25, 100);

for si=1:nsubs
    subplot(1,nsubs,si); set(gca, 'FontSize', 16);
    
    switch type{si}
        case {'linear', ''}
            plot(xvals, yvals, 'ro', 'MarkerSize', 10, 'LineWidth', 5);
            hold on;
            plot(xvsteps, gplt.y(xvsteps), 'LineWidth', 5);
            legend({' Original Data', sprintf(' %4.3fx^{%4.3f}', pplt(2), pplt(1))}, 'Location', 'NorthWest');
            axis square; axis tight;

        case {'log','loglog'}
            loglog(xvals, yvals, 'ro', 'MarkerSize', 10, 'LineWidth', 5);
            hold on;
            loglog(xvsteps, gplt.y(xvsteps), 'LineWidth', 5);
            legend({' Original Data', sprintf(' %4.3fx + %4.3f', pplt)}, 'Location', 'NorthWest');
            axis square; 
            xl    = xvsteps([1 end]); yl = gplt.y(xl); %get(gca,'xlim'); yl    = get(gca,'ylim');
            xdiff = diff(log10(xl));        ydiff = diff(log10(yl));    mdiff = max(xdiff,ydiff);
            xl2   = 10.^(log10(xl) + (mdiff-xdiff)/2*[-1 1]); if (xl2(1)<0), xl2=xl2-xl2(1); end;
            yl2   = 10.^(log10(yl) + (mdiff-ydiff)/2*[-1 1]); if (yl2(1)<0), yl2=yl2-yl2(1); end;
            %lims  = [min([xl2(1) yl2(1)]) max([xl2(2) yl2(2)])];
            set(gca, 'xlim', xl2, 'ylim', yl2 );
            
        otherwise, error('Unknown type: %s', type{si}); 
            
    end;
end;

subplot(1,nsubs,1);