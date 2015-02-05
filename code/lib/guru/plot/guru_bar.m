function guru_bar(b,e,xt, varargin)

  bar(b);
  hold on;
  %x =
  h = errorbar(b,e, 'g', 'LineWidth', 2.0, 'Marker', 'none', 'LineStyle', 'none' ,varargin{:});
  mfe_errorbar_tick(h, 10);
  if (exist('xt','var'))
    set(gca,'xtick',1:length(b),'xticklabel',xt);
  end;